-- ===================================================================================================================================================
/*
	Table's data:		[Master].[Customers], [Master].[CustomerAddresses], [Master].[Addresses], [Master].[Orders]
	Short description:	Function that shows data about an individual customer
	Created on:			2020-12-16
	Modified on:		2020-12-17
	Scripted by:		SOFTSERVE\alevc
*/
-- ===================================================================================================================================================

CREATE FUNCTION [Master].[FN_CustomerProfile]
(
	@CustomerId int
)
RETURNS @Profile TABLE
(
	CustomerId INT, 
    FirstName VARCHAR(50), 
    LastName VARCHAR(50), 
    Email VARCHAR(100), 
    Phone VARCHAR(20),
	NumberOfAddresses INT,
	PendingOrders INT
)
AS
BEGIN
	INSERT INTO @Profile
	SELECT C.CustomerId,
		FirstName,
		LastName,
		Email,
		Phone,
		COUNT(DISTINCT A.AddressId) AS NumberOfAddresses,
		COUNT(DISTINCT IIF(OrderStatusId <> 3, O.OrderId, NULL)) AS PendingOrders
	FROM [Master].[Customers] AS C
	LEFT JOIN [Master].[CustomerAddresses] AS CA ON C.CustomerId = CA.CustomerId
	LEFT JOIN [Master].[Addresses] AS A ON CA.AddressId = A.AddressId
	LEFT JOIN [Master].[Orders] AS O ON C.CustomerId = O.CustomerId
	WHERE C.CustomerId = @CustomerId
	GROUP BY C.CustomerId, FirstName, LastName, Email, Phone
	RETURN
END
