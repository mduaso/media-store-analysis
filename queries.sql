/* Monthly sales per most popular genre */

WITH PopularGenre AS (SELECT g.Name, SUM(il.Quantity*il.UnitPrice) AS PurchaseGenre
    FROM Invoice i
    JOIN InvoiceLine il
    ON i.InvoiceId = il.InvoiceId
    JOIN Track t
    ON t.TrackId = il.TrackId
    JOIN Genre g
    ON g.GenreId = t.GenreId
    GROUP BY g.Name
    ORDER BY PurchaseGenre DESC
    LIMIT 1)

SELECT pg.Name AS GenreName, strftime('%m', InvoiceDate) AS Month, SUM(il.Quantity*il.UnitPrice) AS PurchaseMonth
FROM Invoice i
JOIN InvoiceLine il
ON i.InvoiceId = il.InvoiceId
JOIN Track t
ON t.TrackId = il.TrackId
JOIN Genre g
ON g.GenreId = t.GenreId
JOIN PopularGenre pg
ON g.Name = pg.Name
WHERE g.Name = pg.Name
GROUP BY Month
ORDER BY Month;

/* Relationship between Albums Released and Units Sold in USA */

WITH AlbumUnitsSold AS (SELECT  ar.Name AS ArtistName, al.Title AS AlbumTitle, SUM(il.Quantity) AS UnitsSold
	FROM Album al
	JOIN Artist ar
	ON ar.ArtistId = al.ArtistId
	JOIN Track t
	ON al.AlbumId = t.AlbumId
	JOIN InvoiceLine il
	ON t.TrackId = il.TrackId
	JOIN Invoice i
	ON i.InvoiceId = il.InvoiceId
	JOIN Customer c
	ON c.CustomerId = i.CustomerId
	WHERE c.Country = "USA"
	GROUP BY AlbumTitle)

SELECT ArtistName, COUNT(AlbumTitle) AS AlbumsReleased, SUM(UnitsSold) AS UnitsSold
FROM AlbumUnitsSold
GROUP BY ArtistName;

/* Earnings Top Artist Per Country */

WITH TAE AS (SELECT ar.Name AS TopArtist, SUM(il.Quantity*il.UnitPrice) AS Earnings
	FROM Artist ar
	JOIN Album al
	ON ar.ArtistId = al.ArtistId
	JOIN Track t
	ON al.AlbumId = t.AlbumId
	JOIN InvoiceLine il
	ON t.TrackId = il.TrackId
	GROUP BY TopArtist
	ORDER BY Earnings DESC
	LIMIT 1)
	
SELECT TAE.TopArtist AS TopArtist, c.Country, SUM(il.Quantity*il.UnitPrice) AS EarningsCountry
FROM Artist ar
JOIN Album al
ON ar.ArtistId = al.ArtistId
JOIN Track t
ON al.AlbumId = t.AlbumId
JOIN InvoiceLine il
ON t.TrackId = il.TrackId
JOIN Invoice i
ON i.InvoiceId = il.InvoiceId
JOIN Customer c
ON c.CustomerId = i.CustomerId
JOIN TAE
ON ar.Name = TAE.TopArtist
WHERE ar.Name = TAE.TopArtist
GROUP BY c.Country;

/* TV Shows Length */

SELECT al.Title AS AlbumTitle, (SUM(t.Milliseconds)/60000) AS AlbumLengthMinutes
FROM Track t
JOIN Album al
ON al.AlbumId = t.AlbumId
JOIN Genre g
ON g.GenreId = t.GenreId
WHERE g.Name LIKE "TV Shows"
GROUP BY AlbumTitle
ORDER BY AlbumLengthMinutes DESC;