"use strict";
/**
 * Broker request definitions.
 */

/** List of definitions. */
const definitions = {
    /** Header */
    SIGNATURE: 'x-pot-signature',
    APP_TOKEN: 'x-app-token',
    USER_TOKEN: 'x-user-token',
    /** Body */
    TIMESTAMP: 'timestamp',
    IDS: 'ids',
    PARAMETERS: 'parameters',
    CONTEXT: '@context',
    PRODUCT_CODE: 'productCode',

    /** Signspace specifc body parameters */
    SIGNSPACE_ORGANIZATION_ID: "parameters.idOfficial",
    SIGNSPACE_COUNTRY_CODE: "parameters.country"   ,
    SIGNSPACE_CATEGORY_FILTER: "parameters.categorizationSource",
    SIGNSPACE_STATUS_FILTER: "parameters.status",
    MAX_RESULTS: "parameters.limit",
    RESULTS_OFFSET: "parameters.offset",
    START_TIME_FILTER: "parameters.startTime",
    END_TIME_FILTER: "parameters.endTime",
    QUERY_TEXT: "parameters.queryText",
    SIGNSPACE_TAG_FILTER: "parameters.filter"
};

/** List of supported headers, and if they're required or not. */
const supportedHeaders = {
    [definitions.SIGNATURE]: {
        required: true
    },
    [definitions.APP_TOKEN]: {
        required: true
    },
    [definitions.USER_TOKEN]: {
        required: false
    }
};

/** List of supported parameters, and if they're required or not. */
const supportedParameters = {
    [definitions.TIMESTAMP] : {
        required: true
    },
    [definitions.PARAMETERS] : {
        required: true
    },
    [definitions.SIGNSPACE_ORGANIZATION_ID] : {
        required: true
    },
    [definitions.SIGNSPACE_COUNTRY_CODE] : {
        required: true
    },
    [definitions.IDS] : {
        required: false
    },
    [definitions.CONTEXT] : {
        required: false
    },
    [definitions.SIGNSPACE_CATEGORY_FILTER] : {
        required: false
    },
    [definitions.SIGNSPACE_STATUS_FILTER] : {
        required: false
    },
    [definitions.RESULTS_OFFSET] : {
        required: false
    },
    [definitions.MAX_RESULTS] : {
        required: false
    },
    [definitions.START_TIME_FILTER] : {
        required: false
    },
    [definitions.END_TIME_FILTER] : {
        required: false
    },
    [definitions.QUERY_TEXT] : {
        required: false
    },
    [definitions.SIGNSPACE_TAG_FILTER] : {
        required: true
    },
    [definitions.PRODUCT_CODE] : {
        required: false
    }
};

/**
 * Expose definitions.
 */
module.exports = {
    ...definitions,
    supportedHeaders,
    supportedParameters
};
