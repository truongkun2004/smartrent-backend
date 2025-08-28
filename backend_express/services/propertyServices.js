const { sql } = require("../config/database");

// === Properties ===
async function getHostProperties(hostId) {
  try {
    const request = new sql.Request();
    request.input('HostId', sql.Int, hostId);
    const result = await request.execute('GetHostProperties');
    return result.recordset;
  } catch (err) {
    throw err;
  }
}

async function getPropertyDetail(propertyId) {
    try {
        const pool = await sql.connect();
        const result = await pool.request()
            .input("property_id", sql.Int, propertyId)
            .execute("GetPropertyDetail");

        if (!result.recordsets || result.recordsets.length === 0) {
            return null;
        }

        const propertyInfo = result.recordsets[0][0];

        // Amenities property: [{id, name}, ...]
        const amenities = result.recordsets[1].map(a => ({
            id: a.id,
            name: a.name
        }));

        // Property rooms
        const rooms = result.recordsets[2].map(r => ({
            room_id: r.room_id,
            name: r.name,
            description: r.description,
            images: r.images,
            amenities: [] // gắn sau
        }));

        // Room amenities
        const roomAmenities = result.recordsets[3];
        for (const room of rooms) {
            room.amenities = roomAmenities
                .filter(ra => ra.room_id === room.room_id)
                .map(ra => ({
                    id: ra.amenity_id,
                    name: ra.name
                }));
        }

        return {
            ...propertyInfo,
            amenities,
            propertyRooms: rooms
        };
    } catch (err) {
        console.error("Error in getPropertyDetail:", err);
        throw err;
    }
}

async function addProperty(data) {
  try {
    const request = new sql.Request();
    request.input('name', sql.NVarChar(200), data.name);
    request.input('host_id', sql.Int, data.host_id);
    request.input('type_id', sql.Int, data.type_id);
    request.input('price', sql.Decimal(18, 0), data.price);
    request.input('area', sql.Decimal(10, 2), data.area || null);
    request.input('rooms', sql.Int, data.rooms || null);
    request.input('address', sql.NVarChar(300), data.address || null);
    request.input('description', sql.NVarChar(sql.MAX), data.description || null);
    request.input('contact_info', sql.NVarChar(200), data.contact_info || null);
    request.input('images', sql.NVarChar(sql.MAX), data.images || null);

    const result = await request.execute('AddProperty');
    return result.recordset[0]; // { NewPropertyID: ... }
  } catch (err) {
    throw err;
  }
}

async function updateProperty(id, data) {
  try {
    const request = new sql.Request();
    request.input('id', sql.Int, id);
    request.input('name', sql.NVarChar(200), data.name || null);
    request.input('host_id', sql.Int, data.host_id || null);
    request.input('type_id', sql.Int, data.type_id || null);
    request.input('price', sql.Decimal(18, 0), data.price || null);
    request.input('area', sql.Decimal(10, 2), data.area || null);
    request.input('rooms', sql.Int, data.rooms || null);
    request.input('address', sql.NVarChar(300), data.address || null);
    request.input('description', sql.NVarChar(sql.MAX), data.description || null);
    request.input('contact_info', sql.NVarChar(200), data.contact_info || null);
    request.input('images', sql.NVarChar(sql.MAX), data.images || null);

    await request.execute('UpdateProperty');
    return true;
  } catch (err) {
    throw err;
  }
}

async function togglePropertyAvailability(id) {
  try {
    const request = new sql.Request();
    request.input('id', sql.Int, id);
    const result = await request.execute('TogglePropertyAvailability');
    return result.recordset[0]; // { id, is_available }
  } catch (err) {
    throw err;
  }
}

async function deleteProperty(id) {
  try {
    const request = new sql.Request();
    request.input('id', sql.Int, id);
    await request.execute('DeleteProperty');
    return true;
  } catch (err) {
    throw err;
  }
}

// === Property Amenities ===
async function addPropertyAmenity(propertyId, amenityId) {
  try {
    const request = new sql.Request();
    request.input('PropertyId', sql.Int, propertyId);
    request.input('AmenityId', sql.Int, amenityId);
    await request.execute('AddPropertyAmenity');
    return true;
  } catch (err) {
    throw err;
  }
}

async function getPropertyAmenities(propertyId) {
  try {
    const request = new sql.Request();
    request.input('PropertyId', sql.Int, propertyId);
    const result = await request.execute('GetPropertyAmenities');
    return result.recordset; // list { property_amenity_id, amenity_id, amenity_name }
  } catch (err) {
    throw err;
  }
}

async function clearPropertyAmenities(propertyId) {
  try {
    const request = new sql.Request();
    request.input('PropertyId', sql.Int, propertyId);
    await request.execute('ClearPropertyAmenities');
    return true;
  } catch (err) {
    throw err;
  }
}

// === Property Rooms ===
async function addPropertyRoom(propertyId, name, description, images) {
  try {
    const request = new sql.Request();
    request.input('PropertyId', sql.Int, propertyId);
    request.input('Name', sql.NVarChar(100), name);
    request.input('Description', sql.NVarChar(500), description || null);
    request.input('images', sql.NVarChar(sql.MAX), images || null);
    await request.execute('AddPropertyRoom');
    return true;
  } catch (err) {
    throw err;
  }
}

async function getPropertyRoomIds(propertyId) {
  try {
    const request = new sql.Request();
    request.input('PropertyId', sql.Int, propertyId);
    const result = await request.execute('GetPropertyRoomIds');
    return result.recordset; // list { id }
  } catch (err) {
    throw err;
  }
}

async function updatePropertyRoom(roomId, name, description, images) {
  try {
    const request = new sql.Request();
    request.input('RoomId', sql.Int, roomId);
    request.input('Name', sql.NVarChar(100), name);
    request.input('Description', sql.NVarChar(500), description || null);
    request.input('images', sql.NVarChar(sql.MAX), images || null);
    await request.execute('UpdatePropertyRoom');
    return true;
  } catch (err) {
    throw err;
  }
}

async function togglePropertyRoomAvailability(roomId) {
  try {
    const request = new sql.Request();
    request.input('RoomId', sql.Int, roomId);
    const result = await request.execute('TogglePropertyRoomAvailability');
    return result.recordset[0];
  } catch (err) {
    throw err;
  }
}

async function deletePropertyRoom(roomId) {
  try {
    const request = new sql.Request();
    request.input('RoomId', sql.Int, roomId);
    await request.execute('DeletePropertyRoom');
    return true;
  } catch (err) {
    throw err;
  }
}

// === Room Amenities ===
async function addRoomAmenity(roomId, amenityId) {
  try {
    const request = new sql.Request();
    request.input('RoomId', sql.Int, roomId);
    request.input('AmenityId', sql.Int, amenityId);
    await request.execute('AddRoomAmenity');
    return true;
  } catch (err) {
    throw err;
  }
}

async function clearRoomAmenities(roomId) {
  try {
    const request = new sql.Request();
    request.input('RoomId', sql.Int, roomId);
    await request.execute('ClearRoomAmenities');
    return true;
  } catch (err) {
    throw err;
  }
}

module.exports = {
  getHostProperties,
  getPropertyDetail,
  addProperty,
  updateProperty,
  togglePropertyAvailability,
  deleteProperty,
  addPropertyAmenity,
  getPropertyAmenities,
  clearPropertyAmenities,
  addPropertyRoom,
  getPropertyRoomIds,
  updatePropertyRoom,
  togglePropertyRoomAvailability,
  deletePropertyRoom,
  addRoomAmenity,
  clearRoomAmenities
};
