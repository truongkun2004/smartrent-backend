const express = require("express");
const router = express.Router();
const hostController = require("../controllers/hostControllers");

router.post("/", hostController.addHost);
router.put("/:id", hostController.updateHost);
router.delete("/:id", hostController.deleteHost);
router.post("/login", hostController.loginHost);

module.exports = router;
