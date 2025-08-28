const express = require("express");
const router = express.Router();
const userControllers = require("../controllers/userControllers");

router.post("/", userControllers.addUser);

router.put("/:id", userControllers.updateUser);

router.delete("/:id", userControllers.deleteUser);

router.post("/login", userControllers.loginUser);

module.exports = router;
