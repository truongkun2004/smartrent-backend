const express = require("express");
const router = express.Router();
const userControllers = require("../controllers/userControllers");

router.post("/", userControllers.addUser);

router.put("/:id", userControllers.updateUser);

router.delete("/:id", userControllers.deleteUser);

router.post("/login", userControllers.loginUser);

router.post("/favorites/toggle", userControllers.toggleFavorite);

router.get("/favorites/:userId", userControllers.getFavorites);

router.post("/reviews", userControllers.addReview);

module.exports = router;
