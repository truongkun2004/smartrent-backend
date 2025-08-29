const express = require('express');
const router = express.Router();

const propertyControllers = require('../controllers/propertyControllers');

router.get("/:id", propertyControllers.getPropertyDetail);
router.post('/', propertyControllers.addProperty);
router.put('/:propertyId', propertyControllers.updateProperty);
router.patch('/:propertyId/toggle', propertyControllers.togglePropertyAvailability); // Toggle availability
router.delete('/:propertyId', propertyControllers.deleteProperty); // Delete

// === Property Rooms ===
router.patch('/rooms/:roomId/toggle', propertyControllers.togglePropertyRoomAvailability); // Toggle room
router.delete('/rooms/:roomId', propertyControllers.deletePropertyRoom);

router.post("/approval", propertyControllers.setPropertyApprovalStatus);
router.post("/search", propertyControllers.searchProperties);

router.get("/reviews/:propertyId", propertyControllers.getReviews);

module.exports = router;