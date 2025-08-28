USE SmartRent;
GO

CREATE OR ALTER PROCEDURE GetAllServices
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        id AS service_id,
        name AS service_name,
        cost,
        duration
    FROM PostingServices;
END;
GO

CREATE OR ALTER PROCEDURE GetServicesByProperty
    @PropertyId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        ps.id AS service_id,
        ps.name AS service_name,
        ps.cost AS base_cost,
        pt.price_multiplier,
        (ps.cost * pt.price_multiplier) AS final_cost,
        ps.duration
    FROM PostingServices ps
    CROSS JOIN Properties p
    INNER JOIN PropertyTypes pt ON p.type_id = pt.id
    WHERE p.id = @PropertyId;
END;
GO

CREATE OR ALTER PROCEDURE CreateContract
    @PropertyId INT,
    @HostId INT,
    @ServiceId INT,
    @Quantity INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Duration INT, @Cost DECIMAL(18,0), @PriceMultiplier DECIMAL(5,2);

    -- Lấy thông tin dịch vụ
    SELECT @Duration = duration, @Cost = cost
    FROM PostingServices
    WHERE id = @ServiceId;

    IF @Duration IS NULL
    BEGIN
        RAISERROR('Service not found', 16, 1);
        RETURN;
    END

    -- Lấy hệ số giá từ PropertyTypes
    SELECT @PriceMultiplier = ISNULL(pt.price_multiplier, 1.0)
    FROM Properties p
    LEFT JOIN PropertyTypes pt ON p.type_id = pt.id
    WHERE p.id = @PropertyId;

    IF @PriceMultiplier IS NULL
    BEGIN
        RAISERROR('Property not found', 16, 1);
        RETURN;
    END

    -- Tạo hợp đồng nháp (chưa có start/end)
    INSERT INTO Contracts (property_id, price_multiplier, service_id, cost, quantity, duration, host_id, status)
    VALUES (@PropertyId, @PriceMultiplier, @ServiceId, @Cost, @Quantity, @Duration, @HostId, 0);

    SELECT SCOPE_IDENTITY() AS NewContractId;
END
GO

CREATE OR ALTER PROCEDURE PayContract
    @ContractId INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @HostId INT, @Cost DECIMAL(18,0), @Quantity INT, @Multiplier DECIMAL(5,2), 
            @Duration INT, @Total DECIMAL(18,0), @Balance DECIMAL(18,0), 
            @StartDate DATE, @EndDate DATE;

    -- Lấy thông tin hợp đồng
    SELECT @HostId = host_id, 
           @Cost = cost, 
           @Quantity = quantity, 
           @Multiplier = price_multiplier,
           @Duration = duration
    FROM Contracts
    WHERE id = @ContractId AND status = 0;

    IF @HostId IS NULL
    BEGIN
        RAISERROR('Contract not found or already paid', 16, 1);
        RETURN;
    END

    -- Tính tổng tiền
    SET @Total = CAST(@Cost * @Quantity * @Multiplier AS DECIMAL(18,0));

    -- Kiểm tra số dư
    SELECT @Balance = balance FROM Hosts WHERE id = @HostId;

    IF @Balance < @Total
    BEGIN
        RAISERROR('Insufficient balance', 16, 1);
        RETURN;
    END

    -- Ngày bắt đầu và kết thúc
    SET @StartDate = CAST(GETDATE() AS DATE);
    SET @EndDate = DATEADD(DAY, @Duration * @Quantity, @StartDate);

    -- Trừ tiền host
    UPDATE Hosts
    SET balance = balance - @Total
    WHERE id = @HostId;

    -- Cập nhật trạng thái hợp đồng + start/end date
    UPDATE Contracts
    SET status = 1,
        start_date = @StartDate,
        end_date = @EndDate
    WHERE id = @ContractId;

    -- Ghi giao dịch
    INSERT INTO Transactions (host_id, type, amount, contract_id)
    VALUES (@HostId, 'withdraw', @Total, @ContractId);
END
GO

CREATE OR ALTER PROCEDURE GetContractById
    @ContractId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        c.id,
        c.property_id,
        p.name AS property_name,
        c.service_id,
        s.name AS service_name,
        c.price_multiplier,
        c.cost,
        c.quantity,
        c.duration,
        c.start_date,
        c.end_date,
        c.host_id,
        c.created_at,
        c.status
    FROM Contracts c
    INNER JOIN Properties p ON c.property_id = p.id
    INNER JOIN PostingServices s ON c.service_id = s.id
    WHERE c.id = @ContractId;
END
GO

CREATE OR ALTER PROCEDURE GetContractsByProperty
    @PropertyId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        c.id,
        c.property_id,
        p.name AS property_name,
        c.service_id,
        s.name AS service_name,
        c.price_multiplier,
        c.cost,
        c.quantity,
        c.duration,
        c.start_date,
        c.end_date,
        c.host_id,
        c.created_at,
        c.status
    FROM Contracts c
    INNER JOIN Properties p ON c.property_id = p.id
    INNER JOIN PostingServices s ON c.service_id = s.id
    WHERE c.property_id = @PropertyId
    ORDER BY c.created_at DESC;
END
GO

CREATE OR ALTER PROCEDURE GetTransactionsByHost
    @HostId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        t.id,
        t.type,
        t.amount,
        t.created_at,
        t.contract_id,
        c.property_id,
        p.name AS property_name,
        c.service_id,
        s.name AS service_name
    FROM Transactions t
    LEFT JOIN Contracts c ON t.contract_id = c.id
    LEFT JOIN Properties p ON c.property_id = p.id
    LEFT JOIN PostingServices s ON c.service_id = s.id
    WHERE t.host_id = @HostId
    ORDER BY t.created_at DESC;
END
GO
