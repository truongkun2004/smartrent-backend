USE SmartRent;
GO

-- 1. Thêm Amenity mới
CREATE PROCEDURE AddAmenity
    @name NVARCHAR(100)
AS
BEGIN
    INSERT INTO Amenities (name)
    VALUES (@name);

    SELECT SCOPE_IDENTITY() AS NewAmenityID; -- trả về ID vừa thêm
END
GO

-- 2. Xóa Amenity theo ID
CREATE PROCEDURE DeleteAmenity
    @id INT
AS
BEGIN
    DELETE FROM Amenities
    WHERE id = @id;
END
GO

-- 3. Lấy danh sách tất cả Amenities
CREATE PROCEDURE GetAmenities
AS
BEGIN
    SELECT id, name
    FROM Amenities
    ORDER BY name;
END
GO
