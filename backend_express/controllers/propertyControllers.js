const propertyServices = require('../services/propertyServices');

async function addProperty(req, res) {
  try {
    const {
      name,
      host_id,
      type_id,
      price,
      area,
      rooms: roomCount,
      address,
      description,
      contact_info,
      images,
      amenities, // array of amenity_id
      propertyRooms // array of rooms: { name, description, images, amenity_ids }
    } = req.body;

    const property = await propertyServices.addProperty({
      name,
      host_id,
      type_id,
      price,
      area,
      rooms: roomCount,
      address,
      description,
      contact_info,
      images
    });

    const propertyId = property.NewPropertyID;

    if (Array.isArray(amenities)) {
      for (const amenityId of amenities) {
        await propertyServices.addPropertyAmenity(propertyId, amenityId);
      }
    }

    if (Array.isArray(propertyRooms)) {
      for (const room of propertyRooms) {
        const { name: roomName, description: roomDesc, images: roomImages, amenity_ids } = room;

        await propertyServices.addPropertyRoom(propertyId, roomName, roomDesc, roomImages);

        const roomIds = await propertyServices.getPropertyRoomIds(propertyId);
        const newRoomId = roomIds[roomIds.length - 1].id; // lấy room cuối cùng vừa thêm

        if (Array.isArray(amenity_ids)) {
          for (const amenityId of amenity_ids) {
            await propertyServices.addRoomAmenity(newRoomId, amenityId);
          }
        }
      }
    }

    return res.status(201).json({ success: true, propertyId });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, message: err.message });
  }
}

async function updateProperty(req, res) {
  try {
    const propertyId = parseInt(req.params.propertyId); // Lấy từ route
    const {
      name,
      host_id,
      type_id,
      price,
      area,
      rooms: roomCount,
      address,
      description,
      contact_info,
      images,
      amenities, // array of amenity_id cho property
      propertyRooms // array: { room_id, name, description, images, amenity_ids }
    } = req.body;

    // 1. Update property cơ bản
    await propertyServices.updateProperty(propertyId, {
      name,
      host_id,
      type_id,
      price,
      area,
      rooms: roomCount,
      address,
      description,
      contact_info,
      images
    });

    // 2. Cập nhật property-level amenities
    await propertyServices.clearPropertyAmenities(propertyId);
    if (Array.isArray(amenities)) {
      for (const amenityId of amenities) {
        await propertyServices.addPropertyAmenity(propertyId, amenityId);
      }
    }

    // 3. Xử lý propertyRooms
    const existingRoomIds = (await propertyServices.getPropertyRoomIds(propertyId)).map(r => r.id);
    const incomingRoomIds = propertyRooms.map(r => r.room_id).filter(id => id != null);

    // 3a. Xóa các room thừa trong DB
    for (const roomId of existingRoomIds) {
      if (!incomingRoomIds.includes(roomId)) {
        await propertyServices.deletePropertyRoom(roomId);
      }
    }

    // 3b. Add/update các room trong payload
    for (const room of propertyRooms) {
      const { room_id, name: roomName, description: roomDesc, images: roomImages, amenity_ids } = room;

      let currentRoomId = room_id;

      if (room_id == null) {
        // Add mới
        await propertyServices.addPropertyRoom(propertyId, roomName, roomDesc, roomImages);
        const roomIdsAfterAdd = await propertyServices.getPropertyRoomIds(propertyId);
        currentRoomId = roomIdsAfterAdd[roomIdsAfterAdd.length - 1].id;
      } else {
        // Update có sẵn
        await propertyServices.updatePropertyRoom(room_id, roomName, roomDesc, roomImages);
      }

      // Clear/add room-level amenities
      await propertyServices.clearRoomAmenities(currentRoomId);
      if (Array.isArray(amenity_ids)) {
        for (const amenityId of amenity_ids) {
          await propertyServices.addRoomAmenity(currentRoomId, amenityId);
        }
      }
    }

    return res.status(200).json({ success: true });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, message: err.message });
  }
}

async function togglePropertyAvailability(req, res) {
  try {
    const propertyId = parseInt(req.params.propertyId);
    const result = await propertyServices.togglePropertyAvailability(propertyId);
    return res.status(200).json({ success: true, property: result });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, message: err.message });
  }
}

async function deleteProperty(req, res) {
  try {
    const propertyId = parseInt(req.params.propertyId);
    await propertyServices.deleteProperty(propertyId);
    return res.status(200).json({ success: true });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, message: err.message });
  }
}

async function togglePropertyRoomAvailability(req, res) {
  try {
    const roomId = parseInt(req.params.roomId);
    const result = await propertyServices.togglePropertyRoomAvailability(roomId);
    return res.status(200).json({ success: true, room: result });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, message: err.message });
  }
}

async function deletePropertyRoom(req, res) {
  try {
    const roomId = parseInt(req.params.roomId);
    await propertyServices.deletePropertyRoom(roomId);
    return res.status(200).json({ success: true });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, message: err.message });
  }
}

async function getPropertyDetail(req, res) {
    try {
        const propertyId = parseInt(req.params.id, 10);
        if (isNaN(propertyId)) {
            return res.status(400).json({ message: "Invalid property ID" });
        }

        const property = await propertyServices.getPropertyDetail(propertyId);
        if (!property) {
            return res.status(404).json({ message: "Property not found" });
        }

        res.json(property);
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: "Internal server error" });
    }
}


const setPropertyApprovalStatus = async (req, res) => {
  try {
    const { propertyId, status } = req.body;

    if (!propertyId || status === undefined) {
      return res.status(400).json({ error: "propertyId and status are required" });
    }

    const result = await propertyServices.setPropertyApprovalStatus(propertyId, status);
    res.json(result);
  } catch (err) {
    res.status(500).json({ error: "Internal server error" });
  }
};

const searchProperties = async (req, res) => {
  try {
    const filters = {
      user_id: req.body.user_id,
      type_name: req.body.type_name,
      keyword: req.body.keyword,
      province: req.body.province,
      district: req.body.district,
      ward: req.body.ward,
      min_price: req.body.min_price,
      max_price: req.body.max_price,
      min_area: req.body.min_area,
      max_area: req.body.max_area,
      amenity_ids: req.body.amenity_ids || []
    };

    const properties = await propertyServices.searchPublishedProperties(filters);

    // ✅ Trả thẳng list JSON
    res.json(properties);
  } catch (err) {
    console.error("SearchPublishedProperties error:", err);
    res.status(500).json({ message: "Server error" });
  }
};

async function getReviews(req, res) {
    try {
        const propertyId = parseInt(req.params.propertyId, 10);
        const reviews = await propertyServices.getPropertyReviews(propertyId);
        res.json(reviews);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: "Internal server error" });
    }
}
module.exports = {
  addProperty,
  updateProperty,
  togglePropertyAvailability,
  deleteProperty,
  togglePropertyRoomAvailability,
  deletePropertyRoom,
  getPropertyDetail,
  setPropertyApprovalStatus,
  searchProperties,
  getReviews
};
