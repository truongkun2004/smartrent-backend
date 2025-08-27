USE SmartRent;
GO

-- 1. Thêm host mới
CREATE PROCEDURE AddHost
    @name NVARCHAR(100),
    @gender NVARCHAR(10) = NULL,
    @dob DATE = NULL,
    @address NVARCHAR(255) = NULL,
    @phone NVARCHAR(20) = NULL,
    @email NVARCHAR(255) = NULL,
    @password NVARCHAR(255) = NULL,
    @firebase_id NVARCHAR(255) = NULL
AS
BEGIN
    INSERT INTO Hosts (name, gender, dob, address, phone, email, password, firebase_id)
    VALUES (@name, @gender, @dob, @address, @phone, @email, @password, @firebase_id);

    SELECT SCOPE_IDENTITY() AS NewHostID;
END
GO

-- 2. Cập nhật host
CREATE PROCEDURE UpdateHost
    @id INT,
    @name NVARCHAR(100) = NULL,
    @gender NVARCHAR(10) = NULL,
    @dob DATE = NULL,
    @address NVARCHAR(255) = NULL,
    @phone NVARCHAR(20) = NULL,
    @email NVARCHAR(255) = NULL
AS
BEGIN
    UPDATE Hosts
    SET 
        name = COALESCE(@name, name),
        gender = COALESCE(@gender, gender),
        dob = COALESCE(@dob, dob),
        address = COALESCE(@address, address),
        phone = COALESCE(@phone, phone),
        email = COALESCE(@email, email)
    WHERE id = @id;
END
GO

-- 3. Xóa host
CREATE PROCEDURE DeleteHost
    @id INT
AS
BEGIN
    DELETE FROM Hosts
    WHERE id = @id;
END
GO

-- 4. Tìm host
CREATE OR ALTER PROCEDURE FindHost
    @firebase_id NVARCHAR(255) = NULL,
    @account NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @firebase_id IS NOT NULL
    BEGIN
        SELECT id, name, created_at, password
        FROM Hosts
        WHERE firebase_id = @firebase_id;
    END
    ELSE IF @account IS NOT NULL
    BEGIN
        SELECT id, name, created_at, password
        FROM Hosts
        WHERE email = @account OR phone = @account;
    END
    ELSE
    BEGIN
        -- Trường hợp không có input hợp lệ -> trả về rỗng thay vì undefined
        SELECT NULL AS id, NULL AS name, NULL AS created_at, NULL AS password
        WHERE 1 = 0; -- trick để trả recordset rỗng
    END
END
GO
