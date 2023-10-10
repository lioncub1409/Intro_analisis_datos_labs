DELIMITER //
CREATE PROCEDURE etl_lab2()
BEGIN
    CREATE TABLE resultados AS
    SELECT *,
			-- condiciones del fraude
           CASE
               WHEN InvestigatorAction = '' AND FeedbackType = '' THEN 'Approve Sistema'
               WHEN InvestigatorAction = '' AND FeedbackType = 'fraud' THEN 'Fraude Sistema'
               WHEN InvestigatorAction <> '' AND FeedbackType = '' THEN 'Approve Investigador'
               WHEN InvestigatorAction <> '' AND FeedbackType = 'fraud' THEN 'Fraude Investigador'
               WHEN InvestigatorAction <> '' AND FeedbackType = 'false positive' THEN 'Falso Positivo'
               ELSE 'Otro Caso'
           END AS Clasificacion,
           -- condiciones del score
           CASE
               WHEN Score BETWEEN 0 AND 1500 THEN '<1500'
               WHEN Score BETWEEN 1501 AND 2500 THEN '1501-2500'
               WHEN Score > 2501 THEN '>2501'
           END AS RangoScore,
           -- transformo la moneda
           (Amount * c.ExchangeRate) AS AmountInCurrency
    FROM fn_feed.feed t
    LEFT JOIN Currency c ON t.Currency = c.CurrencyCode
    WHERE PNR IS NOT NULL;

    -- Eliminar duplicados
    DELETE t1
    FROM resultados t1
    JOIN resultados t2
    ON t1.PNR = t2.PNR
    WHERE t1.EventTime > t2.EventTime;
END;
//
DELIMITER ;

-- llamo a mi etl
CALL etl_lab2();
