USE SmartRent;
GO

-- FOR ProperTypes

-- 1. Thêm PropertyType mới
CREATE OR ALTER PROCEDURE AddPropertyType
    @name NVARCHAR(100),
    @has_details BIT = 0,
    @description NVARCHAR(500) = NULL
AS
BEGIN
    INSERT INTO PropertyTypes (name, has_details, description)
    VALUES (@name, @has_details, @description);

    SELECT SCOPE_IDENTITY() AS NewPropertyTypeID; -- trả về ID vừa thêm
END
GO

-- 2. Cập nhật PropertyType
CREATE OR ALTER PROCEDURE UpdatePropertyType
    @id INT,
    @name NVARCHAR(100) = NULL,
    @has_details BIT = NULL,
    @description NVARCHAR(500) = NULL
AS
BEGIN
    UPDATE PropertyTypes
    SET
        name = COALESCE(@name, name),
        has_details = COALESCE(@has_details, has_details),
        description = COALESCE(@description, description)
    WHERE id = @id;
END
GO

-- 3. Xóa PropertyType theo ID
CREATE OR ALTER PROCEDURE DeletePropertyType
    @id INT
AS
BEGIN
    DELETE FROM PropertyTypes
    WHERE id = @id;
END
GO

-- 4. Lấy danh sách tất cả PropertyTypes
CREATE OR ALTER PROCEDURE GetPropertyTypes
AS
BEGIN
    SELECT id, name, has_details, description
    FROM PropertyTypes
    ORDER BY name;
END
GO

-- FOR Properties

CREATE OR ALTER PROCEDURE GetHostProperties
    @HostId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT (
        SELECT 
            p.id,
            p.name,
            t.id AS type_id,
            t.name AS type_name,
            p.address,
            p.price,
            p.area,
            p.rooms,
            p.created_at,
            p.is_available,
            p.approval_status,
            CASE 
                WHEN EXISTS (
                    SELECT 1 
                    FROM Contracts c
                    WHERE c.property_id = p.id
                      AND c.end_date > GETDATE()
                ) THEN 1 ELSE 0
            END AS is_published,
            (
                SELECT MAX(c.end_date)
                FROM Contracts c
                WHERE c.property_id = p.id
                  AND c.end_date > GETDATE()
            ) AS contract_end_date
        FROM Properties p
        JOIN PropertyTypes t ON p.type_id = t.id
        WHERE p.host_id = @HostId
        FOR JSON PATH, INCLUDE_NULL_VALUES
    ) AS json_result;
END
GO

CREATE OR ALTER PROCEDURE GetPropertyDetail
    @property_id INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Thông tin property cơ bản
    SELECT 
        p.id,
        p.name,
        p.host_id,
        p.type_id,
        p.price,
        p.area,
        p.rooms,
        p.address,
        p.description,
        p.contact_info,
        p.images,
        p.is_available,
        p.approval_status AS is_approved,
        ISNULL(AVG(r.rating), 0) AS rating,
        CAST(
            CASE WHEN EXISTS (
                SELECT 1 FROM Contracts c 
                WHERE c.property_id = p.id AND c.end_date >= GETDATE()
            ) THEN 1 ELSE 0 END 
        AS BIT) AS is_published
    FROM Properties p
    LEFT JOIN PropertyReviews r ON p.id = r.property_id AND r.status = 1
    WHERE p.id = @property_id
    GROUP BY 
        p.id, p.name, p.host_id, p.type_id, p.price, p.area, p.rooms,
        p.address, p.description, p.contact_info, p.images,
        p.is_available, p.approval_status;

    -- Danh sách amenities của property (trả cả id + name)
    SELECT a.id, a.name
    FROM PropertyAmenities pa
    INNER JOIN Amenities a ON pa.amenity_id = a.id
    WHERE pa.property_id = @property_id;

    -- Danh sách phòng
    SELECT 
        pr.id AS room_id,
        pr.name,
        pr.description,
        pr.images,
        pr.is_available
    FROM PropertyRooms pr
    WHERE pr.property_id = @property_id;

    -- Tiện ích từng phòng
    SELECT ra.room_id, a.id AS amenity_id, a.name
    FROM RoomAmenities ra
    INNER JOIN Amenities a ON ra.amenity_id = a.id
    INNER JOIN PropertyRooms pr ON ra.room_id = pr.id
    WHERE pr.property_id = @property_id;
END
GO

-- 1. Thêm property mới
CREATE OR ALTER PROCEDURE AddProperty
    @name NVARCHAR(200),
    @host_id INT,
    @type_id INT,
    @price DECIMAL(18,0),
    @area DECIMAL(10,2) = NULL,
    @rooms INT = NULL,
    @address NVARCHAR(300) = NULL,
    @description NVARCHAR(MAX) = NULL,
    @contact_info NVARCHAR(200) = NULL,
    @images NVARCHAR(MAX) = NULL
AS
BEGIN
    INSERT INTO Properties
        (name, host_id, type_id, price, area, rooms, address, description, contact_info, images)
    VALUES
        (@name, @host_id, @type_id, @price, @area, @rooms, @address, @description, @contact_info, @images);

    SELECT SCOPE_IDENTITY() AS NewPropertyID; -- trả về ID vừa thêm
END
GO

-- 2. Cập nhật property
CREATE OR ALTER PROCEDURE UpdateProperty
    @id INT,
    @name NVARCHAR(200) = NULL,
    @host_id INT = NULL,
    @type_id INT = NULL,
    @price DECIMAL(18,0) = NULL,
    @area DECIMAL(10,2) = NULL,
    @rooms INT = NULL,
    @address NVARCHAR(300) = NULL,
    @description NVARCHAR(MAX) = NULL,
    @contact_info NVARCHAR(200) = NULL,
    @images NVARCHAR(MAX) = NULL
AS
BEGIN
    UPDATE Properties
    SET
        name = COALESCE(@name, name),
        host_id = COALESCE(@host_id, host_id),
        type_id = COALESCE(@type_id, type_id),
        price = COALESCE(@price, price),
        area = COALESCE(@area, area),
        rooms = COALESCE(@rooms, rooms),
        address = COALESCE(@address, address),
        description = COALESCE(@description, description),
        contact_info = COALESCE(@contact_info, contact_info),
        images = COALESCE(@images, images)
    WHERE id = @id;
END
GO

-- Toggle is_available
CREATE OR ALTER PROCEDURE TogglePropertyAvailability
    @id INT
AS
BEGIN
    UPDATE Properties
    SET is_available = CASE WHEN is_available = 1 THEN 0 ELSE 1 END
    WHERE id = @id;

    SELECT id, is_available
    FROM Properties
    WHERE id = @id;
END
GO

-- Cập nhật approval_status
CREATE OR ALTER PROCEDURE SetPropertyApprovalStatus
    @PropertyId INT,
    @Status INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Properties
    SET approval_status = @Status
    WHERE id = @PropertyId;
END
GO

-- 3. Xóa property theo ID
CREATE OR ALTER PROCEDURE DeleteProperty
    @id INT
AS
BEGIN
    UPDATE Properties
    SET is_deleted = 1, deleted_at = GETDATE()
    WHERE id = @id
END
GO

-- 4. Quản lý tiện nghi (Amenity)
CREATE OR ALTER PROCEDURE AddPropertyAmenity
    @PropertyId INT,
    @AmenityId INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1 
        FROM PropertyAmenities
        WHERE property_id = @PropertyId AND amenity_id = @AmenityId
    )
    BEGIN
        INSERT INTO PropertyAmenities (property_id, amenity_id)
        VALUES (@PropertyId, @AmenityId);
    END
    ELSE
    BEGIN
        PRINT 'Amenity đã tồn tại cho property này.';
    END
END
GO

CREATE OR ALTER PROCEDURE GetPropertyAmenities
    @PropertyId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT pa.id AS property_amenity_id,
           a.id AS amenity_id,
           a.name AS amenity_name
    FROM PropertyAmenities pa
    JOIN Amenities a ON pa.amenity_id = a.id
    WHERE pa.property_id = @PropertyId;
END
GO

CREATE OR ALTER PROCEDURE ClearPropertyAmenities
    @PropertyId INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM PropertyAmenities
    WHERE property_id = @PropertyId;
END
GO

-- 5. Quản lý loại phòng (PropertyRooms)
CREATE OR ALTER PROCEDURE AddPropertyRoom
    @PropertyId INT,
    @Name NVARCHAR(100),
    @Description NVARCHAR(500) = NULL,
    @images NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO PropertyRooms (property_id, name, description, images)
    VALUES (@PropertyId, @Name, @Description, @images);
END
GO

CREATE OR ALTER PROCEDURE GetPropertyRoomIds
    @PropertyId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT r.id
    FROM PropertyRooms r
    WHERE r.property_id = @PropertyId
END
GO

CREATE OR ALTER PROCEDURE UpdatePropertyRoom
    @RoomId INT,
    @Name NVARCHAR(100),
    @Description NVARCHAR(500),
    @images NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE PropertyRooms
    SET name = @Name,
        description = @Description,
        images = @images
    WHERE id = @RoomId;
END
GO

CREATE OR ALTER PROCEDURE TogglePropertyRoomAvailability
    @RoomId INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE PropertyRooms
    SET is_available = CASE WHEN is_available = 1 THEN 0 ELSE 1 END
    WHERE id = @RoomId;

    SELECT id, name, is_available, description
    FROM PropertyRooms
    WHERE id = @RoomId;
END
GO

CREATE OR ALTER PROCEDURE DeletePropertyRoom
    @RoomId INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM PropertyRooms
    WHERE id = @RoomId
END
GO

CREATE OR ALTER PROCEDURE AddRoomAmenity
    @RoomId INT,
    @AmenityId INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1
        FROM RoomAmenities
        WHERE room_id = @RoomId AND amenity_id = @AmenityId
    )
    BEGIN
        INSERT INTO RoomAmenities (room_id, amenity_id)
        VALUES (@RoomId, @AmenityId);
    END
    ELSE
    BEGIN
        PRINT 'Amenity này đã tồn tại trong room.';
    END
END
GO

CREATE OR ALTER PROCEDURE ClearRoomAmenities
    @RoomId INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM RoomAmenities
    WHERE room_id = @RoomId;
END
GO

-- FOR Reviews
CREATE OR ALTER PROCEDURE AddPropertyReview
    @PropertyId INT,
    @UserId INT,
    @Rating INT,
    @Comment NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO PropertyReviews (property_id, user_id, rating, comment)
    VALUES (@PropertyId, @UserId, @Rating, @Comment);

    SELECT *
    FROM PropertyReviews
    WHERE id = SCOPE_IDENTITY();
END
GO

CREATE OR ALTER PROCEDURE GetPropertyReviews
    @PropertyId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT r.id, r.property_id, r.user_id, r.rating, r.comment, r.created_at, r.status,
           u.name AS user_name
    FROM PropertyReviews r
    JOIN Users u ON r.user_id = u.id
    WHERE r.property_id = @PropertyId
    ORDER BY r.created_at DESC;
END
GO

CREATE OR ALTER PROCEDURE DeletePropertyReview
    @ReviewId INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM PropertyReviews
    WHERE id = @ReviewId;
END
GO

-- FOR User Favourie
CREATE OR ALTER PROCEDURE AddUserFavorite
    @UserId INT,
    @PropertyId INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1 
        FROM UserFavorites 
        WHERE user_id = @UserId AND property_id = @PropertyId
    )
    BEGIN
        INSERT INTO UserFavorites (user_id, property_id)
        VALUES (@UserId, @PropertyId);
    END
    ELSE
    BEGIN
        PRINT 'Đã có trong danh sách yêu thích.';
    END
END
GO

CREATE OR ALTER PROCEDURE RemoveUserFavorite
    @UserId INT,
    @PropertyId INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM UserFavorites
    WHERE user_id = @UserId AND property_id = @PropertyId;
END
GO

CREATE OR ALTER PROCEDURE GetUserFavorites
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT f.id AS favorite_id,
           p.id AS property_id,
           p.name AS property_name,
           p.address,
           p.price,
           p.area,
           p.rooms,
           p.is_available
    FROM UserFavorites f
    JOIN Properties p ON f.property_id = p.id
    WHERE f.user_id = @UserId
    ORDER BY f.id DESC;
END
GO
