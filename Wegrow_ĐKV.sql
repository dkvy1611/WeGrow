-- BẢNG MKT:

SELECT *
FROM [dbo].[MKT];

-- Kiểm tra kiểu dữ liệu của các cột:

SELECT COLUMN_NAME,
       DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'MKT';

-- Tính lại các cột Giá_Lead, CPM, CPC:

UPDATE [dbo].[MKT]
SET Giá_Lead = CASE
                   WHEN Chi_phí_Marketing <> 0
                        AND Lead_MKT <> 0 THEN ROUND(Chi_phí_Marketing / Lead_MKT, 0)
                   ELSE ROUND(Giá_Lead, 0)
               END,
               CPM = CASE
                         WHEN Chi_phí_Marketing <> 0
                              AND Impression <> 0 THEN ROUND(Chi_phí_Marketing / Impression * 1000, 0)
                         ELSE CPM
                     END,
                     CPC = CASE
                               WHEN Chi_phí_Marketing <> 0
                                    AND Click <> 0 THEN ROUND(Chi_phí_Marketing / Click, 0)
                               ELSE CPC
                           END;

-- Thêm cột ME1 mới để bổ sung những giá trị tính sai ở cột cũ:

ALTER TABLE [dbo].[MKT] ADD ME1_fix FLOAT;


UPDATE [dbo].[MKT]
SET ME1_fix = CASE
                  WHEN Channel = 'FB' THEN round(Chi_phí_Marketing*1.08, 0)
                  WHEN Channel = 'Google' THEN round(Chi_phí_Marketing, 0)
                  WHEN Channel = 'Tiktok' THEN round(Chi_phí_Marketing*1.05, 0)
              END;


UPDATE [dbo].[MKT]
SET ME1_ME_đã_bao_gồm_thuế_phí = CASE
                                     WHEN ME1_fix = 0 THEN ME1_ME_đã_bao_gồm_thuế_phí
                                     ELSE ME1_fix
                                 END;

-- Thêm cột Chi phí MKT mới để fill lại những ô có giá trị = 0:

UPDATE [dbo].[MKT]
SET Chi_phí_Marketing = CASE
                            WHEN Channel = 'FB' THEN round(ME1_ME_đã_bao_gồm_thuế_phí/1.08, 0)
                            WHEN Channel = 'Google' THEN round(ME1_ME_đã_bao_gồm_thuế_phí, 0)
                            WHEN Channel = 'Tiktok' THEN round(ME1_ME_đã_bao_gồm_thuế_phí/1.05, 0)
                        END;

-- BẢNG SALES

SELECT *
FROM [dbo].[Sales];

-- Tạo View để chỉnh sửa dữ liệu:

CREATE VIEW SalesView AS
SELECT *
FROM [dbo].[Sales]
WHERE Ngày IS NOT NULL;


SELECT *
FROM SalesView;

-- Kiểm tra data type của các cột

SELECT COLUMN_NAME,
       DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'SalesView';

-- Cột Số tiền giảm giá và Tổng tiền bị lỗi dấu '.' và ',' nên mất phần nghìn đằng sau. Sửa lại:

UPDATE SalesView
SET Số_tiền_giảm_giá = CASE
                           WHEN Số_tiền_giảm_giá > 0 THEN Số_tiền_giảm_giá*1000
                           WHEN Số_tiền_giảm_giá < 0 THEN Số_tiền_giảm_giá*(-1000)
                       END,
                       Tổng_tiền = Tổng_tiền*1000,
                       Trạng_thái = CASE
                                        WHEN Trạng_thái IS NULL
                                             AND left(LEVEL, 4) = 'C3.2' THEN 'Trùng'
                                        WHEN Trạng_thái IS NULL
                                             AND left(LEVEL, 4) = 'L2.2' THEN 'Từ chối'
                                        WHEN Trạng_thái IS NULL
                                             AND left(LEVEL, 4) = 'L8.2' THEN 'Đặt hàng'
                                        ELSE Trạng_thái
                                    END;

--BẢNG VẬN ĐƠN:

SELECT *
FROM [dbo].[Logistics]
ORDER BY STT -- Tạo View để chỉnh sửa dữ liệu:

CREATE VIEW Vandon AS
SELECT *
FROM [dbo].[Logistics]
WHERE STT IS NOT NULL;


SELECT *
FROM Vandon;

-- Kiểm tra data type của các cột

SELECT COLUMN_NAME,
       DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Vandon';


UPDATE Vandon
SET [Kích_thước_DxRxC] = CASE
                             WHEN [Kích_thước_DxRxC] = '0.000x0.000x0.000' THEN '10.000x10.000x10.000'
                             ELSE [Kích_thước_DxRxC]
                         END;
