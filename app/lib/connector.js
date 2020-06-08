"use strict";
/**
 * Module dependencies.
 */
const rest = require('../protocols/rest');
const validator = require('./validator');
const _ = require('lodash');
const axios = require('axios');
const qs = require("qs");
const fs = require('fs');

if (process.env.NODE_ENV !== 'production') {
    require('dotenv').config();
}

// Set directories.
const configsDir = './config';

// Make sure directories for templates, protocols, configs and plugins exists.
if (!fs.existsSync(configsDir)) fs.mkdirSync(configsDir);

/**
 * Connector library.
 *
 * Handles data fetching and translation.
 */

/** Import platform of trust definitions. */
const {
    SIGNSPACE_ORGANIZATION_ID,
    SIGNSPACE_COUNTRY_CODE,
    SIGNSPACE_STATUS_FILTER,
    RESULTS_OFFSET,
    MAX_RESULTS,
    IDS,
    START_TIME_FILTER,
    END_TIME_FILTER,
    QUERY_TEXT,
    SIGNSPACE_TAG_FILTER,
    supportedParameters
} = require('../../config/definitions/request');

/**
 * Consumes described resources.
 *
 * @param {Object} reqBody
 * @return {Array} Data array.
 */
const getData = async (reqBody) => {
    
    /** Parameter validation */
    const validation = validator.validate(reqBody, supportedParameters);
    if (Object.hasOwnProperty.call(validation, 'error')) {
        if (validation.error) return rest.promiseRejectWithError(422, validation.error);
    }

    const signspaceClientId = process.env.CONFIGS ? loadJSON('client_id', process.env.CONFIGS) : process.env.SIGNSPACE_CLIENT_ID;
    const signspaceClientSecret = process.env.CONFIGS ? loadJSON('client_secret', process.env.CONFIGS) : process.env.SIGNSPACE_CLIENT_SECRET;
    const signspaceOrganizationId = _.get(reqBody, SIGNSPACE_ORGANIZATION_ID);
    const signspaceCountryCode = _.get(reqBody, SIGNSPACE_COUNTRY_CODE);
    const signspaceStatusFilter = _.get(reqBody, SIGNSPACE_STATUS_FILTER);
    const resultsOffset = _.get(reqBody, RESULTS_OFFSET);
    const maxResults = _.get(reqBody, MAX_RESULTS);
    const ids = _.get(reqBody, IDS);
    const startTime = _.get(reqBody, START_TIME_FILTER);
    const endTime = _.get(reqBody, END_TIME_FILTER);
    const textQuery = _.get(reqBody, QUERY_TEXT);
    const signspaceTagFilter = _.get(reqBody, SIGNSPACE_TAG_FILTER);
   
    let tokenResponse = "";
    let queryString = `business_id=${signspaceOrganizationId}&country_code=${signspaceCountryCode}&type=signing_request`;
    
    /** Parameter vailidation and responses */
    try {
        tokenResponse = await axios({
            method: 'post',
            url: process.env.CONFIGS ? loadJSON('auth_url', process.env.CONFIGS) : process.env.SIGNSPACE_AUTH_URL,
            auth: {
                username: signspaceClientId,
                password: signspaceClientSecret
            },
            data: qs.stringify({
                grant_type: "client_credentials",
                scope: "signspace_api tasks.searchByOrg"
            }),
            headers: {
                'content-type': 'application/x-www-form-urlencoded;charset=utf-8'
            }
        });
        
        if (signspaceStatusFilter !== null && signspaceStatusFilter !== undefined) {
            if(!Array.isArray(signspaceStatusFilter)) {
                return rest.promiseRejectWithError(422, "Filter must be an Array");
            } else {
                signspaceStatusFilter.forEach(status => {
                    queryString += `&status=${status.toLowerCase().split(' ').join('_')}`;
                });
            }
        }
            
        if (resultsOffset !== null && resultsOffset !== undefined) {
            queryString += `&offset=${resultsOffset}`;
        }

        if (maxResults !== null && maxResults !== undefined) {
            if(maxResults == 0) {
                return rest.promiseRejectWithError(422, "Please set limit above 0");
            } else {
                queryString += `&limit=${maxResults}`;
            }
        }

        if (startTime !== null && startTime !== undefined && endTime !== null && endTime !== undefined) {
            if (startTime > endTime) {
                return rest.promiseRejectWithError(422, "Notice, endTime should be after the startTime");
            }
        }
        
        if (startTime !== null && startTime !== undefined) {
            queryString += `&latest=${startTime}`;
        }

        if (endTime !== null && endTime !== undefined) {
            queryString += `&oldest=${endTime}`;
        }

        if (textQuery !== null && textQuery !== undefined) {
            queryString += `&q=${encodeURIComponent(textQuery)}`;
        }

        if (signspaceTagFilter[0] !== null && signspaceTagFilter !== undefined) {

            if(!Array.isArray(signspaceTagFilter)) {
                return rest.promiseRejectWithError(422, "Filter must be an Array");
            } else {
                signspaceTagFilter.forEach(tag => {
                queryString += `&tag=${encodeURIComponent(tag)}`;
                });
            }
        } 

    } catch (error) {
        if (error.response && error.response.status) {
            return rest.promiseRejectWithError(error.response.status, error.response.statusText || "Contact server administrator");
        } else {
            return rest.promiseRejectWithError(500, "Contact server administator");
        }
        
    }
    
    const signspaceAccessToken = tokenResponse.data.access_token;
    const tasksResponse = await axios({ method: 'get', url :`${ process.env.CONFIGS ? loadJSON('endpoint', process.env.CONFIGS) : process.env.SIGNSPACE_ENDPOINT }?${ queryString }`, headers: { 'Authorization': `Bearer ${ signspaceAccessToken }` } });
    const tasks = tasksResponse.data.tasks;
    const translatedTasks = [];
    
    for (let i = 0; i < tasks.length; i++) {
        let taskIncluded = true;
        if (ids && ids.length > 0 && ids.filter(id => tasks[i]._id === id).length < 1) {
            taskIncluded = false;
        }

        if (taskIncluded) {
            const translatedTask = {};
            
            translatedTask.url = tasks[i].message_url;
            translatedTask.digitalSignaturesRequestedCount = tasks[i].signatures_requested_count;
            translatedTask.digitalSignaturesCompletedCount = tasks[i].signatures_completed_count;
            translatedTask.created = tasks[i].created_at;
            translatedTask.updated = tasks[i].last_updated_at;
            translatedTask.status = capitalizeFirstLetter(tasks[i].status).split('_').join(' ');
            translatedTask.idSource = tasks[i]._id;
            translatedTask.name = tasks[i].title;

            translatedTask.parties = tasks[i].contracting_parties.map(party=> {
                return { "name": party, "@type": "Organization" };
            });

            translatedTask.documents = tasks[i].files.map(document=> {
                return { "name": document, "@type": "Document" };
            });

            const digitalSignatures = [];
            for (let j = 0; j < tasks[i].signed_data.length; j++) {
                const digitalSignature = { "@type": "DigitalSignature" };
                digitalSignature.executor = tasks[i].signed_data[j].signed_by;
                digitalSignature.timestamp = tasks[i].signed_data[j].signed_at;
                digitalSignatures.push(digitalSignature);
            }
    
            translatedTask.digitalSignatures = digitalSignatures;
    
            translatedTasks.push(translatedTask);
        }
    }

    return translatedTasks;
};

/** Utilities */

/**
 * Gets a value from a JSON object using a property name
 * 
 * @param {Object} collection 
 * @param {String} string 
 * 
 * @return property value
 */
const loadJSON = (collection, string) => {
    const object = JSON.parse(Buffer.from(string, 'base64').toString('utf8'));

    if (collection == 'client_id') {
        var client_id = object.SIGNSPACE_CLIENT_ID;
        return client_id;
    }

    if (collection == 'client_secret') {
        var client_secret = object.SIGNSPACE_CLIENT_SECRET;
        return client_secret;
    }

    if (collection == 'auth_url') {
        var auth_url = object.SIGNSPACE_AUTH_URL;
        return auth_url;
    }

    if (collection == 'endpoint') {
        var endpoint = object.SIGNSPACE_ENDPOINT;
        return endpoint;
    }

    else {
        return null;
    }
}

/** Capitalizes a given string
 * 
 *  @param {String} string
 *  @return {String} capitalized string
 */
const capitalizeFirstLetter = (string) => {
    return string.charAt(0).toUpperCase() + string.slice(1);
  }

/**
 * Expose library functions.
 */
module.exports = {
    getData
};
