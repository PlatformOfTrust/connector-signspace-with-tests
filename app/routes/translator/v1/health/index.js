"use strict";
/**
 * Module dependencies.
 */
const router = require('express').Router();
const ctrl = require('../../../../controllers/status');

/**
 * Status routes.
 */
module.exports = function () {
    /** Platform of Trust health endpoint. */
    router.post('', ctrl.healthCheck);

    return router;
};
