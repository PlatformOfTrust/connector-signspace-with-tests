"use strict";
/**
 * Platform of Trust definitions.
 */

/** Default RSA key size for generated keys. */
const defaultKeySize = 4096;

/** URLs of Platform of Trust public keys. */
const publicKeyURLs = [
    /** Primary keys. */
    {
        env: 'static-test',
        url: 'https://static-test.oftrust.net/keys/translator.pub'
    }
];

/** Context URLs. */
const contextURLs = {
    DataProduct: 'https://standards-ontotest.oftrust.net/v2/Context/DataProductOutput/Document/Signing/SignSpace/'
};

/**
 * Expose definitions.
 */
module.exports = {
    defaultKeySize,
    publicKeyURLs,
    contextURLs
};
