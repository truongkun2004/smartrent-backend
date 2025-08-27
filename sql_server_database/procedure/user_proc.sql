USE SmartRent;
GO

-- 1. Thêm user mới
CREATE PROCEDURE AddUser
    @name NVARCHAR(100),
    @phone NVARCHAR(20) = NULL,
    @email NVARCHAR(255) = NULL,
    @password NVARCHAR(255) = NULL,
    @firebase_id NVARCHAR(255) = NULL
AS
BEGIN
    INSERT INTO Users (name, phone, email, password, firebase_id)
    VALUES (@name, @phone, @email, @password, @firebase_id);

    SELECT SCOPE_IDENTITY() AS NewUserID; -- trả về ID của user mới
END
GO

-- 2. Cập nhật thông tin user
CREATE PROCEDURE UpdateUser
    @id INT,
    @name NVARCHAR(100) = NULL,
    @phone NVARCHAR(20) = NULL,
    @email NVARCHAR(255) = NULL
AS
BEGIN
    UPDATE Users
    SET
        name = COALESCE(@name, name),
        phone = COALESCE(@phone, phone),
        email = COALESCE(@email, email)
    WHERE id = @id;
END
GO

-- 3. Xóa user
CREATE PROCEDURE DeleteUser
    @id INT
AS
BEGIN
    DELETE FROM Users
    WHERE id = @id;
END
GO
