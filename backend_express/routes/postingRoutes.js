const express = require("express");
const router = express.Router();
const postingControllers = require("../controllers/postingControllers");

// Services
router.get("/services", postingControllers.getAllServices);
router.get("/services/property/:propertyId", postingControllers.getServicesByProperty);

// Contracts
router.post("/contracts", postingControllers.createContract);
router.post("/contracts/pay", postingControllers.payContract);
router.get("/contracts/:contractId", postingControllers.getContractById);
router.get("/contracts/property/:propertyId", postingControllers.getContractsByProperty);

// Transactions
router.get("/transactions/host/:hostId", postingControllers.getTransactionsByHost);

module.exports = router;
