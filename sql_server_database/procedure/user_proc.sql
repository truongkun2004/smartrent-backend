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

CREATE OR ALTER PROCEDURE FindUser
    @firebase_id NVARCHAR(255) = NULL,
    @account NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @firebase_id IS NOT NULL
    BEGIN
        SELECT id, name, created_at, password
        FROM Users
        WHERE firebase_id = @firebase_id;
    END
    ELSE IF @account IS NOT NULL
    BEGIN
        SELECT id, name, created_at, password
        FROM Users
        WHERE email = @account OR phone = @account;
    END
    ELSE
    BEGIN
        -- Không có input hợp lệ -> trả rỗng
        SELECT NULL AS id, NULL AS name, NULL AS created_at, NULL AS password
        WHERE 1 = 0;
    END
END
GO

CREATE OR ALTER PROCEDURE AddPropertyReview
    @PropertyId INT,
    @UserId INT,
    @Rating DECIMAL(3,1),
    @Comment NVARCHAR(500)
AS
BEGIN
    INSERT INTO PropertyReviews (property_id, user_id, rating, comment, created_at, status)
    VALUES (@PropertyId, @UserId, @Rating, @Comment, GETDATE(), 1);
END
GO

CREATE OR ALTER PROCEDURE GetPropertyReviews
    @PropertyId INT
AS
BEGIN
    SELECT pr.id,
           pr.user_id,
           u.name AS user_name,
           pr.rating,
           pr.comment,
           pr.created_at
    FROM PropertyReviews pr
    INNER JOIN Users u ON pr.user_id = u.id
    WHERE pr.property_id = @PropertyId
      AND pr.status = 1
    ORDER BY pr.created_at DESC;
END
GO
