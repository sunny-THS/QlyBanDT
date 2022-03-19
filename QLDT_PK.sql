USE master
IF EXISTS(SELECT * FROM sys.databases WHERE name='QLDT_LK')
BEGIN
        DROP DATABASE QLDT_LK
END
CREATE DATABASE QLDT_LK
GO
USE QLDT_LK
GO

-- tạo bảng
-- GR ADMIN(00): CONTROL ALL
-- GR NHÂN VIÊN(01): HỖ TRỢ KHÁCH HÀNG XỬ LÝ ĐƠN HÀNG
-- GR KHÁCH HÀNG(02): NGƯỜI DÙNG
CREATE TABLE GRTK (
    ID INT IDENTITY NOT NULL,
    TEN NVARCHAR(50), -- TÊN GR
    CODEGR CHAR(2),
    CONSTRAINT PK_GR PRIMARY KEY (ID) 
)
CREATE TABLE TAIKHOAN (
    ID VARCHAR(15) NOT NULL, -- CREATE AUTO
    USERNAME VARCHAR(50), -- CHECK USERNAME THEO GROUP
    PW VARBINARY(50), -- MÃ HÓA + salt
    ID_GR INT REFERENCES GRTK(ID),
    CONSTRAINT PK_TK PRIMARY KEY (ID)
)
CREATE TABLE THONGTINTAIKHOAN (
    ID VARCHAR(20) NOT NULL, -- CREATE AUTO
    HOTEN NVARCHAR(50), -- HỌ TÊN
    NGSINH DATE, -- NGÀY SINH
    GTINH BIT, -- 1: NAM, 0: NỮ, NULL: CHƯA BIẾT(QUY VỀ 0)
    NGTAO DATE, -- NGÀY TẠO
    EMAIL VARCHAR(50), -- ĐỊA CHỈ EMAIL
    SDT VARCHAR(11), -- SDT
    DCHI NVARCHAR(50), -- ĐỊA CHỈ NHÀ / ĐỊA CHỈ GIAO
    ID_TAIKHOAN VARCHAR(15) REFERENCES TAIKHOAN(ID) ON DELETE CASCADE,
    CONSTRAINT PK_TTTK PRIMARY KEY (ID)
)
CREATE TABLE KHACHHANG (
    ID VARCHAR(10) NOT NULL, -- CREATE AUTO
    ID_TK VARCHAR(15),
    DIEMTICHLUY INT,
    CONSTRAINT PK_KH PRIMARY KEY (ID),
    CONSTRAINT FK_KH_TK FOREIGN KEY (ID_TK) REFERENCES TAIKHOAN(ID)
)
CREATE TABLE NHANVIEN (
    ID VARCHAR(10) NOT NULL, -- CREATE AUTO
    ID_TK VARCHAR(15),
	TINHTRANG NVARCHAR(50),
    CONSTRAINT PK_NV PRIMARY KEY (ID),
    CONSTRAINT FK_NV_TK FOREIGN KEY (ID_TK) REFERENCES TAIKHOAN(ID) ON DELETE CASCADE
)
CREATE TABLE DANHMUC ( -- điện thoại & phụ kiện
    ID INT IDENTITY NOT NULL,
    TENDANHMUC NVARCHAR(50),
    CONSTRAINT PK_DMUC PRIMARY KEY (ID)
)
CREATE TABLE LOAISP ( 
    ID VARCHAR(6) NOT NULL,
    TENLOAI NVARCHAR(50), -- android, iphone, điện thoại phổ thông
	IDDM INT REFERENCES DANHMUC(ID), -- LOẠI SP ĐÓ THUỘC DANH MỤC NÀO
    CONSTRAINT PK_LSP PRIMARY KEY (ID)
)
CREATE TABLE HANG ( -- hãng sp
    ID INT IDENTITY NOT NULL,
    TENHANG NVARCHAR(20),
    CONSTRAINT PK_HANG PRIMARY KEY(ID)
)
CREATE TABLE SANPHAM ( -- _________________________________
    ID VARCHAR(5) NOT NULL, -- CREATE AUTO
    TENSP NVARCHAR(MAX), -- TÊN SẢN PHẨM
    SOLUONG INT, -- SỐ LƯỢNG TỒN KHO
    NSX NVARCHAR(30), -- NHÀ SẢN XUẤT
    HINHANH VARCHAR(50),
    ID_LOAI VARCHAR(6) REFERENCES LOAISP(ID),
    ID_HANG INT REFERENCES HANG(ID), -- HÃNG SP
    CONSTRAINT PK_SP PRIMARY KEY (ID)
)
CREATE TABLE CAUHINH (
    ID INT IDENTITY NOT NULL,
    ID_SP VARCHAR(5) REFERENCES SANPHAM(ID),
    TENCAUHINH NVARCHAR(30),
    NOIDUNGCAUHINH NVARCHAR(100),
    CONSTRAINT PK_CH PRIMARY KEY (ID)
)
CREATE TABLE SALE (
    ID INT IDENTITY NOT NULL,
    GIATRI FLOAT, -- GIÁ TRỊ SALE
    ID_SP VARCHAR(5) REFERENCES SANPHAM(ID),
    NGCAPNHAT DATETIME, -- NGÀY CẬP NHẬT SALE LẤY NGÀY GẦN NHẤT
	NGKETTHUC DATETIME,
    CONSTRAINT PK_SALE PRIMARY KEY (ID)
)
CREATE TABLE DONGIA (
    ID INT IDENTITY NOT NULL,
    ID_SP VARCHAR(5) REFERENCES SANPHAM(ID),
    GIA FLOAT, -- GIÁ
    NGCAPNHAT DATETIME, -- NGÀY CẬP NHẬT - LẤY NGÀY MỚI NHẤT
    CONSTRAINT PK_DG PRIMARY KEY (ID, ID_SP)
)
CREATE TABLE HOADON (
    ID VARCHAR(10) NOT NULL, -- CREATE AUTO
    NGTAO DATE, -- NGÀY TẠO HÓA ĐƠN
    DONGIA FLOAT, -- TỔNG (SỐ LƯỢNG * ĐƠN GIÁ) - khuyến mãi nếu có
    ID_KH VARCHAR(10) REFERENCES KHACHHANG(ID),
    ID_NV VARCHAR(10) REFERENCES NHANVIEN(ID),
    CONSTRAINT PK_HD PRIMARY KEY (ID)
)
CREATE TABLE CHITIETHD (
    ID INT IDENTITY NOT NULL,
    ID_HD VARCHAR(10) REFERENCES HOADON(ID),
    ID_SP VARCHAR(5) REFERENCES SANPHAM(ID),
    SOLUONG INT, -- SỐ LƯỢNG > 0, số lượng bán
    CONSTRAINT PK_CTHD PRIMARY KEY (ID, ID_HD) 
)
CREATE TABLE PHIEUNHAP (
    ID VARCHAR(10) NOT NULL, -- CREATE AUTO
    NGTAO DATE, -- NGÀY TẠO PHIẾU NHẬP
    DONGIA FLOAT, -- TỔNG (SỐ LƯỢNG * ĐƠN GIÁ)
    CONSTRAINT PK_PN PRIMARY KEY (ID)
)
CREATE TABLE CHITIETPN (
    ID INT IDENTITY NOT NULL,
    ID_PN VARCHAR(10) REFERENCES PHIEUNHAP(ID),
    ID_SP VARCHAR(5) REFERENCES SANPHAM(ID),
    SOLUONG INT, -- SỐ LƯỢNG > 0, số lượng bán
    CONSTRAINT PK_CTPN PRIMARY KEY (ID, ID_PN) 
)
CREATE TABLE THONGKETRUYCAP (
    ID INT IDENTITY NOT NULL,
    ISONL BIT, -- KIỂM TRA CÒN ONL - DEFAULT: 1(ON)
    NGGHI DATETIME, -- NGÀY GHI NHẬN
    NGOFF DATETIME, -- KHI NGƯỜI DÙNG KẾT THÚC PHIÊN
    CONSTRAINT PK_TKTC PRIMARY KEY (ID)   
)
GO

-- CREATE TABLE VIEW 
CREATE VIEW rndVIEW
AS
SELECT RAND() rndResult
GO

----------------------------------------------------------
--  ___   Proc                     _   ___   Func       --
-- | _ \_ _ ___  __   __ _ _ _  __| | | __|  _ _ _  __  --
-- |  _/ '_/ _ \/ _| / _` | ' \/ _` | | _| || | ' \/ _| --
-- |_| |_| \___/\__| \__,_|_||_\__,_| |_| \_,_|_||_\__| --
----------------------------------------------------------

-- function
CREATE FUNCTION fn_hash(@text VARCHAR(50))
RETURNS VARBINARY(MAX)
AS
BEGIN
	RETURN HASHBYTES('SHA2_256', @text);
END
GO

CREATE FUNCTION fn_getRandom ( -- TRẢ VỀ 1 SỐ NGẪU NHIÊN
	@min int, 
	@max int
)
RETURNS INT
AS
BEGIN
    RETURN FLOOR((SELECT rndResult FROM rndVIEW) * (@max - @min + 1) + @min);
END
GO

CREATE FUNCTION fn_getCodeGr(@tenGr VARCHAR(50)) -- TRẢ VỀ CODE GR
RETURNS CHAR(2)
AS
BEGIN
    DECLARE @CODEGR CHAR(2)
    SELECT @CODEGR = CODEGR FROM GRTK WHERE TEN = @tenGr

    RETURN @CODEGR
END
GO

--------------------------------------------------------------------------------------

CREATE  FUNCTION fn_ConvertFirstLetterinCapital(@Text NVARCHAR(MAX)) 
RETURNS NVARCHAR(MAX) 
AS 
	BEGIN
		DECLARE @Index INT;
		DECLARE @FirstChar NCHAR(1);
		DECLARE @LastChar NCHAR(1);
		DECLARE @String NVARCHAR(MAX);

		SET @String = LOWER(@Text);
		SET @Index = 1;
		WHILE @Index <= LEN(@Text)
			BEGIN
				SET @FirstChar = SUBSTRING(@Text, @Index, 1);
				SET @LastChar = CASE
									WHEN @Index = 1
									THEN ' '
									ELSE SUBSTRING(@Text, @Index - 1, 1)
								END;
				IF @LastChar IN(' ', ';', ':', '!', '?', ',', '.', '_', '-', '/', '&', '''', '(', '#', '*', '$', '@')
					BEGIN
						IF @FirstChar != ''''
							OR UPPER(@FirstChar) != 'S'
							SET @String = STUFF(@String, @Index, 1, UPPER(@FirstChar));
				END;
				SET @Index = @Index + 1;
			END;
				RETURN @String;
	END;
GO



---------------------------------------------------------------------------------------

CREATE FUNCTION fn_Ten(@idTK VARCHAR(15)) -- TRẢ VỀ CODE GR
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @TEN NVARCHAR(50)
    SELECT @TEN = HOTEN FROM THONGTINTAIKHOAN WHERE ID_TAIKHOAN = @idTK

    RETURN DBO.fn_ConvertFirstLetterinCapital(@TEN)
END
GO

CREATE FUNCTION fn_autoIDTK(@TENGR VARCHAR(50)) -- id TÀI KHOẢN
RETURNS VARCHAR(15)
AS
BEGIN
	DECLARE @ID VARCHAR(15)
	DECLARE @maCodeGr CHAR(2)
	DECLARE @IDGR INT

    -- LẤY MÃ GR
    SELECT @IDGR=ID, @maCodeGr = CODEGR FROM GRTK WHERE TEN = @TENGR

	IF (SELECT COUNT(ID) FROM TAIKHOAN WHERE ID_GR = @IDGR) = 0
		SET @ID = '0'
	ELSE
		SELECT @ID = MAX(RIGHT(ID, 3)) FROM TAIKHOAN WHERE ID_GR = @IDGR

    DECLARE @ngayTao VARCHAR(8) = convert(VARCHAR, getdate(), 112) -- format yyyymmdd
    DECLARE @stt VARCHAR(5) = CONVERT(VARCHAR, CONVERT(INT, @ID) + 1)

	SELECT @ID = CASE
		WHEN @ID >= 99 THEN @ngayTao + @maCodeGr + @stt
		WHEN @ID >=  9 THEN @ngayTao + @maCodeGr + '0' + @stt
		WHEN @ID >=  0 and @ID < 9 THEN @ngayTao + @maCodeGr + '00' + @stt
	END

	RETURN @ID
END
GO

CREATE FUNCTION fn_autoIDKH() -- id KHÁCH HÀNG
RETURNS VARCHAR(10)
AS
BEGIN
	DECLARE @ID VARCHAR(10)

	IF (SELECT COUNT(ID) FROM KHACHHANG) = 0
		SET @ID = '0'
	ELSE
		SELECT @ID = MAX(RIGHT(ID, 3)) FROM KHACHHANG

    DECLARE @stt VARCHAR(5) = CONVERT(VARCHAR, CONVERT(INT, @ID) + 1)
    DECLARE @maCode CHAR(2) = 'KH'

	SELECT @ID = CASE
		WHEN @ID >= 99 THEN @maCode + @stt
		WHEN @ID >=  9 THEN @maCode + '0' + @stt
		WHEN @ID >=  0 and @ID < 9 THEN @maCode + '00' + @stt
	END

	RETURN @ID
END
GO

CREATE FUNCTION fn_autoIDNV() -- id NHÂN VIÊN
RETURNS VARCHAR(10)
AS
BEGIN
	DECLARE @ID VARCHAR(10)

	IF (SELECT COUNT(ID) FROM NHANVIEN) = 0
		SET @ID = '0'
	ELSE
		SELECT @ID = MAX(RIGHT(ID, 3)) FROM NHANVIEN

    DECLARE @stt VARCHAR(5) = CONVERT(VARCHAR, CONVERT(INT, @ID) + 1)
    DECLARE @maCode CHAR(2) = 'NV'

	SELECT @ID = CASE
		WHEN @ID >= 99 THEN @maCode + @stt
		WHEN @ID >=  9 THEN @maCode + '0' + @stt
		WHEN @ID >=  0 and @ID < 9 THEN @maCode + '00' + @stt
	END

	RETURN @ID
END
GO

CREATE FUNCTION fn_autoIDHD() -- id HÓA ĐƠN
RETURNS VARCHAR(10)
AS
BEGIN
	DECLARE @ID VARCHAR(10)

	IF (SELECT COUNT(ID) FROM HOADON) = 0
		SET @ID = '0'
	ELSE
		SELECT @ID = MAX(RIGHT(ID, 3)) FROM HOADON

    DECLARE @stt VARCHAR(5) = CONVERT(VARCHAR, CONVERT(INT, @ID) + 1)
    DECLARE @maCode CHAR(2) = 'HD'

	SELECT @ID = CASE
		WHEN @ID >= 99 THEN @maCode + @stt
		WHEN @ID >=  9 THEN @maCode + '0' + @stt
		WHEN @ID >=  0 and @ID < 9 THEN @maCode + '00' + @stt
	END

	RETURN @ID
END
GO

CREATE FUNCTION fn_autoIDLSP() -- id LOẠI SP 
RETURNS VARCHAR(6)
AS
BEGIN
	DECLARE @ID VARCHAR(6)

	IF (SELECT COUNT(ID) FROM LOAISP) = 0
		SET @ID = '0'
	ELSE
		SELECT @ID = MAX(RIGHT(ID, 3)) FROM LOAISP

    DECLARE @stt VARCHAR(3) = CONVERT(VARCHAR, CONVERT(INT, @ID) + 1)
    DECLARE @maCode CHAR(3) = 'LSP'

	SELECT @ID = CASE
		WHEN @ID >= 99 THEN @maCode + @stt
		WHEN @ID >=  9 THEN @maCode + '0' + @stt
		WHEN @ID >=  0 and @ID < 9 THEN @maCode + '00' + @stt
	END

	RETURN @ID
END
GO

CREATE FUNCTION fn_autoIDSP() -- id SP
RETURNS VARCHAR(5)
AS
BEGIN
	DECLARE @ID VARCHAR(5)

	IF (SELECT COUNT(ID) FROM SANPHAM) = 0
		SET @ID = '0'
	ELSE
		SELECT @ID = MAX(RIGHT(ID, 3)) FROM SANPHAM

    DECLARE @stt VARCHAR(3) = CONVERT(VARCHAR, CONVERT(INT, @ID) + 1)
	
    DECLARE @maCode CHAR(2) = 'SP'
	
	SELECT @ID = CASE
		WHEN @ID >= 99 THEN @maCode + @stt
		WHEN @ID >=  9 THEN @maCode + '0' + @stt
		WHEN @ID >=  0 and @ID < 9 THEN @maCode + '00' + @stt
	END
	RETURN @ID
END
GO

CREATE FUNCTION fn_autoIDTTND(
    @idLogin VARCHAR(15)
) -- id CỦA THÔNG TIN NGƯỜI DÙNG: IDLOGIN + mã rand
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @randNumber INT = DBO.fn_getRandom(100, 999)
    
    DECLARE @ID VARCHAR(20) = @idLogin + convert(CHAR, @randNumber)

	RETURN @ID
END
GO

-- proc 
CREATE PROC sp_getIDGR -- TRẢ VỀ ID GR
@tenGr NVARCHAR(50)
AS
    DECLARE @IDGR INT
    SELECT @IDGR = ID FROM GRTK WHERE TEN = @tenGr

    RETURN @IDGR 
GO

CREATE PROC sp_GetErrorInfo  
AS  
SELECT  
    ERROR_NUMBER() AS ErrorNumber  
    ,ERROR_SEVERITY() AS ErrorSeverity  
    ,ERROR_STATE() AS ErrorState  
    ,ERROR_PROCEDURE() AS ErrorProcedure  
    ,ERROR_LINE() AS ErrorLine  
    ,ERROR_MESSAGE() AS 'Message';
GO 

--ID INT IDENTITY NOT NULL,
--ID_SP VARCHAR(5) REFERENCES SANPHAM(ID),
--GIA FLOAT, -- GIÁ
--NGCAPNHAT DATETIME, -- NGÀY CẬP NHẬT - LẤY NGÀY MỚI NHẤT
CREATE PROC sp_SetDG -- SET ĐƠN GIÁ
@tenSP NVARCHAR(50),
@gia FLOAT
AS
	BEGIN
		DECLARE @maSP VARCHAR(10)
		SELECT @maSP = ID FROM SANPHAM WHERE TENSP = @tenSP

		INSERT DONGIA(ID_SP, GIA)
		VALUES (@maSP, @gia)
	END
GO
CREATE PROC sp_GetMaHD
@maHD VARCHAR(10) OUTPUT
AS
	SELECT @maHD = DBO.fn_autoIDHD()
GO
--ID VARCHAR(10) NOT NULL, -- CREATE AUTO
--NGTAO DATE, -- NGÀY TẠO HÓA ĐƠN
--DONGIA FLOAT, -- TỔNG (SỐ LƯỢNG * ĐƠN GIÁ)
--ID_KH VARCHAR(10) REFERENCES KHACHHANG(ID),
--ID_NV VARCHAR(10) REFERENCES NHANVIEN(ID)

--ID INT IDENTITY NOT NULL,
--ID_HD VARCHAR(10) REFERENCES HOADON(ID),
--ID_SP VARCHAR(5) REFERENCES SANPHAM(ID),
--SOLUONG INT, -- SỐ LƯỢNG > 0, số lượng bán
CREATE PROC sp_AddHD
@maHD VARCHAR(10),
@tenKH NVARCHAR(50),
@tenNV NVARCHAR(50),
@tenSP NVARCHAR(MAX),
@soLuong INT
AS
	BEGIN TRY
		DECLARE @maNV VARCHAR(10), @maKH VARCHAR(10), @maSP VARCHAR(5)

		IF NOT EXISTS (SELECT * FROM HOADON WHERE ID = @maHD)
		BEGIN
			INSERT HOADON(ID) SELECT @maHD

			-- LẤY MÃ NHÂN VIÊN
			SELECT @maNV = NHANVIEN.ID FROM NHANVIEN JOIN THONGTINTAIKHOAN on THONGTINTAIKHOAN.ID_TAIKHOAN = NHANVIEN.ID_TK WHERE HOTEN = @tenNV
			-- LẤY MÃ KHÁCH HÀNG
			SELECT @maKH = KHACHHANG.ID FROM KHACHHANG JOIN THONGTINTAIKHOAN on THONGTINTAIKHOAN.ID_TAIKHOAN = KHACHHANG.ID_TK WHERE HOTEN = @tenKH

			-- ADD MÃ KHÁCH HÀNG VÀ NHÂN VIÊN VÀO HÓA ĐƠN
			UPDATE HOADON SET ID_KH = @maKH, ID_NV = @maNV WHERE ID = @maHD
		END

		-- LẤY MÃ SẢN PHẨM 
		SELECT @maSP = ID FROM SANPHAM WHERE TENSP = @tenSP

		-- kiểm tra kho
		DECLARE @MESSAGE NVARCHAR(70) = @tenSP + N' đã hết hàng'
		IF @soLuong > (SELECT SOLUONG FROM SANPHAM WHERE TENSP = @tenSP)
			THROW 51000, @MESSAGE, 1;

		-- THÊM THÔNG TIN CHO HÓA ĐƠN
		INSERT CHITIETHD(ID_HD, ID_SP, SOLUONG) SELECT @maHD, @maSP, @soLuong

		-- cập nhật lại số lượng sản phẩm
		UPDATE SANPHAM SET SOLUONG = SOLUONG - @soLuong WHERE ID = @maSP

		-- CẬP NHẬT ĐƠN GIÁ ---------------------- kiểm tra ngày mới nhất trong đơn giá
		DECLARE @donGia FLOAT -- đơn giá của sản phẩm x

		SELECT TOP 1 @donGia = SUM(@soLuong * GIA)
		FROM DONGIA
		WHERE ID_SP = @maSP
		GROUP BY NGCAPNHAT
		ORDER BY NGCAPNHAT DESC
		
		UPDATE HOADON SET DONGIA = DONGIA + @donGia WHERE ID = @maHD
	END TRY
	BEGIN CATCH
		EXEC sp_GetErrorInfo;
	END CATCH
GO

--ID VARCHAR(10) NOT NULL, -- CREATE AUTO
--NGTAO DATE, -- NGÀY TẠO HÓA ĐƠN
--DONGIA FLOAT, -- TỔNG (SỐ LƯỢNG * ĐƠN GIÁ)

--ID INT IDENTITY NOT NULL,
--ID_HD VARCHAR(10) REFERENCES HOADON(ID),
--ID_SP VARCHAR(5) REFERENCES SANPHAM(ID),
--SOLUONG INT, -- SỐ LƯỢNG > 0, số lượng bán
CREATE PROC sp_AddPN
@maPN VARCHAR(10),
@tenSP NVARCHAR(MAX),
@soLuong INT,
@gia FLOAT,
@hinhAnh VARCHAR(50)
AS
	BEGIN TRY
		DECLARE @maSP VARCHAR(5)

		IF NOT EXISTS (SELECT * FROM PHIEUNHAP WHERE ID = @maPN)
		BEGIN
			INSERT PHIEUNHAP(ID) SELECT @maPN
		END

		IF NOT EXISTS(SELECT * FROM SANPHAM WHERE TENSP = @tenSP)
		BEGIN
			EXEC sp_AddSP @tenSP, N'', 0, @gia, '', @hinhAnh, N'', N''
			-- GO
		END
		-- LẤY MÃ SẢN PHẨM 
		SELECT @maSP = ID FROM SANPHAM WHERE TENSP = @tenSP

		-- THÊM THÔNG TIN CHO HÓA ĐƠN
		INSERT CHITIETPN(ID_PN, ID_SP, SOLUONG) SELECT @maPN, @maSP, @soLuong


		-- cập nhật lại số lượng sản phẩm
		UPDATE SANPHAM SET SOLUONG = SOLUONG + @soLuong WHERE ID = @maSP

		-- CẬP NHẬT ĐƠN GIÁ ---------------------- kiểm tra ngày mới nhất trong đơn giá
		DECLARE @donGia FLOAT -- đơn giá của sản phẩm x

		SELECT TOP 1 @donGia = SUM(@soLuong * GIA)
		FROM DONGIA
		WHERE ID_SP = @maSP
		GROUP BY NGCAPNHAT
		ORDER BY NGCAPNHAT DESC
		
		UPDATE PHIEUNHAP SET DONGIA = DONGIA + @donGia WHERE ID = @maPN
	END TRY
	BEGIN CATCH
		EXEC sp_GetErrorInfo;
	END CATCH
GO

CREATE PROC sp_AddLSP -- THÊM LOẠI SP
@tenLSP NVARCHAR(50),
@tenDanhMuc NVARCHAR(50)
AS 
    BEGIN TRY
        IF EXISTS(SELECT * FROM LOAISP WHERE ID = (SELECT ID FROM LOAISP WHERE TENLOAI = @tenLSP))
			THROW 51000, N'Loại sản phẩm đã tồn tại.', 1;

		DECLARE @idDanhMuc INT
        SELECT @idDanhMuc = ID FROM DANHMUC WHERE TENDANHMUC = @tenDanhMuc
		
		INSERT LOAISP(TENLOAI, @idDanhMuc)
		SELECT @tenLSP 

	END TRY
	BEGIN CATCH
		EXEC sp_GetErrorInfo;
	END CATCH
GO
--================================================================================
--ID VARCHAR(5) NOT NULL, -- CREATE AUTO
--TENSP NVARCHAR(50), -- TÊN SẢN PHẨM
--MOTA NVARCHAR(MAX), -- MÔ TẢ
--SOLUONG INT, -- SỐ LƯỢNG TỒN KHO
---- DONGIA FLOAT, -- ĐƠN GIÁ
--NSX NVARCHAR(30), -- NHÀ SẢN XUẤT
--HINHANH VARCHAR(50),
--ID_LOAI VARCHAR(6) REFERENCES LOAISP(ID),
-- HÃNG SP
CREATE PROC sp_AddSP
@tenSP NVARCHAR(MAX),
@tenHang NVARCHAR(20), -- tên hãng sản phẩm
@soLuong INT,
@gia FLOAT,
@nxs NVARCHAR(30),
@urlImage VARCHAR(50),
@tenLSP NVARCHAR(50)
AS
	BEGIN TRY
		DECLARE @IDSP VARCHAR(15) = DBO.fn_autoIDSP() -- id SP
		-- select DBO.fn_autoIDSP() select * from sanpham
		IF EXISTS(SELECT * FROM SANPHAM WHERE TENSP = @tenSP)
			THROW 51000, N'Sản phẩm đã tồn tại.', 1;

		DECLARE @IDLSP VARCHAR(6)
		SELECT @IDLSP = ID FROM LOAISP WHERE TENLOAI = @tenLSP
		
        DECLARE @IDHANG INT -- lấy id hãng sản phẩm
        SELECT @IDHANG = ID FROM HANG WHERE TENHANG = @tenHang

		INSERT SANPHAM(ID, TENSP, SOLUONG, NSX, HINHANH, ID_LOAI, ID_HANG)
		VALUES (@IDSP, @tenSP, @soLuong, @nxs, @urlImage, @IDLSP, @IDHANG)

		INSERT DONGIA(ID_SP, GIA)
		VALUES (@IDSP, @gia)

		SELECT N'SUCCESS' 'Message'
	END TRY
	BEGIN CATCH
		EXEC sp_GetErrorInfo;
	END CATCH
GO

CREATE PROC sp_AddCauHinh
@tenSP NVARCHAR(Max),
@tenCH NVARCHAR(30),
@noiDungCH NVARCHAR(100)
AS
BEGIN TRY
		DECLARE @idSP VARCHAR(5)
        SELECT @idSP = ID FROM SANPHAM WHERE TENSP = @tenSP

        INSERT CAUHINH SELECT @idSP, @tenCH, @noiDungCH
	END TRY
	BEGIN CATCH
		EXEC sp_GetErrorInfo;
	END CATCH
GO

-- ID VARCHAR(20)
-- HOTEN NVARCHAR(50), -- HỌ TÊN
-- NGSINH DATE, -- NGÀY SINH
-- GTINH BIT, -- 1: NAM, 0: NỮ, NULL: CHƯA BIẾT(QUY VỀ 0)
-- NGTAO DATE, -- NGÀY TẠO
-- EMAIL VARCHAR(50), -- ĐỊA CHỈ EMAIL
-- SDT VARCHAR(11), -- SDT
-- DCHI NVARCHAR(50)
CREATE PROC sp_AddAcc
@userName VARCHAR(50), -- THÔNG TIN TÀI KHOẢN
@pw VARCHAR(50),
@GRNAME NVARCHAR(50),
@hoTen NVARCHAR(50),
@ngSinh DATE,
@gioiTinh NVARCHAR(5),
@email VARCHAR(50),
@sdt VARCHAR(11),
@dChi NVARCHAR(50)
AS
	BEGIN TRY
		DECLARE @ID VARCHAR(15) = DBO.fn_autoIDTK(@GRNAME) -- id login

		DECLARE	@createPW VARBINARY(MAX) = SubString(DBO.fn_hash(@ID), 1, len(DBO.fn_hash(@ID))/2) + DBO.fn_hash(@pw + @ID)

		DECLARE @IDGR INT
		EXEC @IDGR = sp_getIDGR @GRNAME -- id gr

        IF (UPPER(@GRNAME) = N'KHÁCH HÀNG')
        BEGIN
            SET @userName = NULL;
            SET @createPW = NULL;
        END

		IF EXISTS(SELECT * FROM TAIKHOAN WHERE ID_GR = @IDGR AND USERNAME = @userName)
			THROW 51000, N'Username đã tồn tại.', 1;

		-- tạo tài khoản
		INSERT TAIKHOAN
		SELECT @ID, @userName, @createPW, @IDGR; 

        IF (UPPER(@GRNAME) = N'NHÂN VIÊN')
        BEGIN
            INSERT NHANVIEN (ID_TK)
            SELECT @ID
        END

        IF (UPPER(@GRNAME) = N'KHÁCH HÀNG')
        BEGIN
            INSERT KHACHHANG(ID_TK)
            SELECT @ID
        END

        DECLARE @GTINH BIT = 0
        IF (UPPER(@gioiTinh) = N'NAM')
            SET @GTINH = 1;

        -- tạo thông tin người dùng
        INSERT THONGTINTAIKHOAN(ID, HOTEN, NGSINH, GTINH, EMAIL, SDT, DCHI, ID_TAIKHOAN)
        VALUES(DBO.fn_autoIDTTND(@ID), UPPER(@hoTen), @ngSinh, @GTINH, @email, @sdt, @dChi, @ID)

		SELECT N'SUCCESS' 'Message'
	END TRY
	BEGIN CATCH
		EXEC sp_GetErrorInfo;
	END CATCH
GO

CREATE PROC sp_ChangeAcc
@userName VARCHAR(50), -- THÔNG TIN TÀI KHOẢN
@pw VARCHAR(50),
@GRNAME NVARCHAR(50)
AS
	BEGIN TRY
		DECLARE @IDGR INT
		EXEC @IDGR = sp_getIDGR @GRNAME -- id gr

		DECLARE @IDTK VARCHAR(15);
		SELECT @IDTK = ID FROM TAIKHOAN WHERE USERNAME = @userName

		DECLARE	@createPW VARBINARY(MAX) = SubString(DBO.fn_hash(@IDTK), 1, len(DBO.fn_hash(@IDTK))/2) + DBO.fn_hash(@pw + @IDTK)

		UPDATE TAIKHOAN SET PW = @createPW WHERE ID = @IDTK AND ID_GR = @IDGR

		SELECT N'SUCCESS' 'Message'
	END TRY
	BEGIN CATCH
		EXEC sp_GetErrorInfo;
	END CATCH
GO

CREATE PROC sp_DelAcc
@userName VARCHAR(50), -- THÔNG TIN TÀI KHOẢN
@pw VARCHAR(50),
@GRNAME NVARCHAR(50)
AS
	BEGIN TRY
		DECLARE @IDGR INT
		EXEC @IDGR = sp_getIDGR @GRNAME -- id gr

		DECLARE @IDTK VARCHAR(15);
		SELECT @IDTK = ID FROM TAIKHOAN WHERE USERNAME = @userName

		UPDATE TAIKHOAN SET PW = NULL, USERNAME = NULL WHERE ID = @IDTK AND ID_GR = @IDGR

		UPDATE NHANVIEN SET TINHTRANG = N'Đã nghỉ' WHERE ID_TK = @IDTK

		SELECT N'SUCCESS' 'Message'
	END TRY
	BEGIN CATCH
		EXEC sp_GetErrorInfo;
	END CATCH
GO

CREATE PROC sp_CKUsername
@userName VARCHAR(50),
@GRNAME NVARCHAR(50)
AS
	BEGIN TRY
		DECLARE @IDGR INT
		EXEC @IDGR = sp_getIDGR @GRNAME -- id gr

		DECLARE @IDTK VARCHAR(15);
		SELECT @IDTK = ID FROM TAIKHOAN WHERE USERNAME = @userName

		IF EXISTS(SELECT * FROM TAIKHOAN WHERE ID_GR = @IDGR AND USERNAME = @userName)
			THROW 51000, N'Username đã tồn tại.', 1;

		SELECT N'ok' 'Message'
	END TRY
	BEGIN CATCH
		EXEC sp_GetErrorInfo;
	END CATCH
GO

CREATE PROC sp_UpTTTK
@maTK VARCHAR(15),
@hoTen NVARCHAR(50),
@ngSinh DATE,
@gioiTinh NVARCHAR(5),
@email VARCHAR(50),
@sdt VARCHAR(11),
@dChi NVARCHAR(50)
AS
	BEGIN TRY
		DECLARE @GTINH BIT = 0
        IF (UPPER(@gioiTinh) = N'NAM')
            SET @GTINH = 1;

        -- tạo thông tin người dùng
		UPDATE THONGTINTAIKHOAN SET HOTEN = @hoTen, 
									NGSINH=@ngSinh, 
									GTINH=@GTINH, 
									EMAIL=@email,
									SDT=@sdt,
									DCHI=@dChi
				WHERE ID_TAIKHOAN=@maTK

		SELECT N'SUCCESS' 'Message'
	END TRY
	BEGIN CATCH
		EXEC sp_GetErrorInfo;
	END CATCH
GO

CREATE PROC sp_CKAcc
@userName VARCHAR(50), -- THÔNG TIN TÀI KHOẢN
@pw VARCHAR(50),
@GRNAME NVARCHAR(50)
AS
	BEGIN TRY
		DECLARE @IDGR INT
		EXEC @IDGR = sp_getIDGR @GRNAME -- id gr

		DECLARE @IDTK VARCHAR(15);
		SELECT @IDTK = ID FROM TAIKHOAN WHERE USERNAME = @userName

		DECLARE	@createPW VARBINARY(MAX) = SubString(DBO.fn_hash(@IDTK), 1, len(DBO.fn_hash(@IDTK))/2) + DBO.fn_hash(@pw + @IDTK)

		IF NOT EXISTS(SELECT * FROM TAIKHOAN WHERE ID_GR = @IDGR AND USERNAME = @userName AND PW = @createPW)
			THROW 51000, N'Thông tin đăng nhập không chính xác.', 1;

		SELECT N'SUCCESS' 'Message'
	END TRY
	BEGIN CATCH
		EXEC sp_GetErrorInfo;
	END CATCH
GO

CREATE PROC sp_ReportHD
@nam int
AS
	SELECT HOADON.ID, CONVERT(varchar,NGTAO,103) NGTAO, DONGIA, DBO.fn_Ten(NHANVIEN.ID_TK) TENNV, DBO.fn_Ten(KHACHHANG.ID_TK) TENKH FROM HOADON JOIN NHANVIEN 
		ON HOADON.ID_NV=NHANVIEN.ID JOIN KHACHHANG
		ON KHACHHANG.ID=HOADON.ID_KH
		WHERE YEAR(NGTAO) = @nam
GO

CREATE PROC sp_ReportBill
@idHD VARCHAR(10),
@tienKH float
AS
	SELECT HOADON.ID, CONVERT(varchar,NGTAO,103) NGTAO, DONGIA, (@tienKH - DONGIA) TIENTHUA, DBO.fn_Ten(NHANVIEN.ID_TK) TENNV, DBO.fn_Ten(KHACHHANG.ID_TK) TENKH, TENSP, CHITIETHD.SOLUONG, GIA GIASP FROM HOADON JOIN NHANVIEN 
		ON HOADON.ID_NV=NHANVIEN.ID JOIN KHACHHANG
		ON KHACHHANG.ID=HOADON.ID_KH JOIN CHITIETHD
		ON CHITIETHD.ID_HD = HOADON.ID JOIN SANPHAM
		ON SANPHAM.ID = CHITIETHD.ID_SP JOIN DONGIA DG
		ON DG.ID_SP = SANPHAM.ID
	WHERE HOADON.ID = @idHD AND
		  DG.ID = (SELECT TOP 1 DONGIA.ID
						FROM DONGIA
						WHERE ID_SP = SANPHAM.ID
						ORDER BY NGCAPNHAT DESC)
GO

CREATE PROC sp_ChartSanPham
@nam int
AS
	SELECT TOP 10 TENSP, SUM(CTHD.SOLUONG) SOLUONGBANRA
	FROM HOADON HD JOIN CHITIETHD CTHD 
		ON HD.ID = CTHD.ID_HD JOIN SANPHAM SP
		ON SP.ID = CTHD.ID_SP
	WHERE YEAR(NGTAO) = @nam
	GROUP BY TENSP
	ORDER BY SOLUONGBANRA DESC
GO

CREATE PROC sp_ChartNhanVien
@nam int
AS
	SELECT HOTEN, SUM(DONGIA) DOANHTHU
	FROM HOADON HD JOIN NHANVIEN NV
		ON NV.ID = HD.ID_NV JOIN THONGTINTAIKHOAN TTTK
		ON TTTK.ID_TAIKHOAN = NV.ID_TK
	WHERE YEAR(HD.NGTAO) = @nam
	GROUP BY HOTEN
	ORDER BY DOANHTHU DESC
GO

CREATE PROC sp_ChartDoanhThu
@nam int
AS
	DECLARE @tbDoanhThu TABLE (THANG INT, DOANHTHU FLOAT)
	INSERT @tbDoanhThu
		SELECT m, SUM(DONGIA) DOANHTHU
		FROM (SELECT * FROM HOADON WHERE YEAR(NGTAO) = @nam) dtn RIGHT JOIN (
			SELECT m
			FROM (VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11), (12))
			[1 to 12](m)
		) listMonth
			ON MONTH(NGTAO)=listMonth.m
		GROUP BY m
		ORDER BY m
	
	UPDATE @tbDoanhThu SET DOANHTHU = 0 WHERE DOANHTHU IS NULL
	SELECT * FROM @tbDoanhThu
GO

CREATE PROC sp_GetKhachHang
AS
	DECLARE @tbKH TABLE(ID VARCHAR(6), HOTEN NVARCHAR(50), SDT VARCHAR(11), EMAIL VARCHAR(40), TONGGIAODICH FLOAT)

	INSERT @tbKH SELECT KH.ID, DBO.fn_Ten(KH.ID_TK) HOTEN, SDT, EMAIL, SUM(DONGIA) TONGGIAODICH
	FROM KHACHHANG KH JOIN THONGTINTAIKHOAN TTTK
		ON KH.ID_TK = TTTK.ID_TAIKHOAN LEFT JOIN HOADON HD
		ON HD.ID_KH = KH.ID
	GROUP BY KH.ID, KH.ID_TK, SDT, EMAIL

	UPDATE @tbKH SET TONGGIAODICH = 0 WHERE TONGGIAODICH IS NULL

	SELECT * FROM @tbKH
GO

-- TẠO RÀNG BUỘC
ALTER TABLE THONGTINTAIKHOAN
ADD CONSTRAINT DF_NGTAO_TTTK DEFAULT GETDATE() FOR NGTAO

ALTER TABLE LOAISP
ADD CONSTRAINT DF_LSP_ID DEFAULT DBO.fn_autoIDLSP() FOR ID

ALTER TABLE DONGIA
ADD CONSTRAINT DF_NGCAPNHAT_DG DEFAULT GETDATE() FOR NGCAPNHAT

ALTER TABLE SALE
ADD CONSTRAINT DF_NGCAPNHAT_S DEFAULT GETDATE() FOR NGCAPNHAT

ALTER TABLE KHACHHANG
ADD CONSTRAINT DF_ID_KH DEFAULT DBO.fn_autoIDKH() FOR ID,
    CONSTRAINT DF_DIEMTICHLUY DEFAULT 0 FOR DIEMTICHLUY

ALTER TABLE NHANVIEN 
ADD CONSTRAINT DF_ID_NV DEFAULT DBO.fn_autoIDNV() FOR ID,
    CONSTRAINT DF_TT_NV DEFAULT N'Còn làm' FOR TINHTRANG

ALTER TABLE HOADON 
ADD CONSTRAINT DF_NGTAO_HD DEFAULT GETDATE() FOR NGTAO,
    CONSTRAINT DF_ID DEFAULT DBO.fn_autoIDHD() FOR ID,
	CONSTRAINT DF_DONGIA DEFAULT 0 FOR DONGIA

ALTER TABLE CHITIETHD
ADD CONSTRAINT CK_SL CHECK (SOLUONG > 0)

ALTER TABLE THONGKETRUYCAP
ADD CONSTRAINT DF_NGGHI DEFAULT GETDATE() FOR NGGHI,
    CONSTRAINT DF_ISONL DEFAULT 1 FOR ISONL

GO

--------------------------------
--  ___           _   data    --
-- |   \   __ _  | |_   __ _  --
-- | |) | / _` | |  _| / _` | --
-- |___/  \__,_|  \__| \__,_| --
--------------------------------

-- BẢNG TB_GRTK
INSERT GRTK VALUES(N'ADMIN', '00')
INSERT GRTK VALUES(N'NHÂN VIÊN', '01')
INSERT GRTK VALUES(N'KHÁCH HÀNG', '02')

-- BẢNG TAIKHOAN
EXEC sp_AddAcc 'admin', 'admin@123456789', N'ADMIN', N'Admin', '2-5-2001', N'nam', 'admin@gmail.com', '000000000', ''
--nhân viên
EXEC sp_AddAcc 'tuhueson', 'tuhueson@123456789', N'Nhân viên', N'Từ Huệ Sơn', '2-5-2001', N'nam', 'tuhueson@gmail.com', '000000000', ''
EXEC sp_AddAcc 'leductai', 'leductai@123456789', N'Nhân viên', N'Lê Đức Tài', '12-4-2001', N'nam', 'leductai@gmail.com', '000000000', ''
EXEC sp_AddAcc 'nguyenvanteo', 'nguyenvanteo@123456789', N'Nhân viên', N'Nguyễn văn Tèo', '12-5-2001', N'nam', 'nguyenvanteo@gmail.com', '000000000', ''
EXEC sp_AddAcc 'trannhattrung', 'trannhattrung@123456789', N'Nhân viên', N'Trần Nhật Trung', '2-14-2001', N'nam', 'trannhattrung@gmail.com', '000000000', ''
EXEC sp_AddAcc 'dogianguyen', 'dogianguyen@123456789', N'Nhân viên', N'Đỗ Gia Nguyên', '12-4-2001', N'nữ', 'dogianguyen@gmail.com', '000000000', ''
EXEC sp_AddAcc 'lytuong', 'lytuong@123456789', N'Nhân viên', N'Lý Tường', '2-4-2001', N'nữ', 'lytuong@gmail.com', '000000000', ''
EXEC sp_AddAcc 'tranvu', 'tranvu@123456789', N'Nhân viên', N'Trần Vũ', '2-15-2001', N'nam', 'tranvu@gmail.com', '000000000', ''
EXEC sp_AddAcc 'doquyen', 'doquyen@123456789', N'Nhân viên', N'Đỗ Quyên', '3-15-2001', N'nữ', 'doquyen@gmail.com', '000000000', ''
EXEC sp_AddAcc 'daokimhue', 'daokimhue@123456789', N'Nhân viên', N'Đào kim huệ', '3-15-2001', N'nữ', 'daokimhue@gmail.com', '000000000', ''
EXEC sp_AddAcc 'hogiacat', 'hogiacat@123456789', N'Nhân viên', N'hồ gia cát', '5-15-2001', N'nam', 'hogiacat@gmail.com', '000000000', ''
EXEC sp_AddAcc 'vuthanhlong', 'vuthanhlong@123456789', N'Nhân viên', N'vũ thanh long', '3-15-2001', N'nam', 'vuthanhlong@gmail.com', '000000000', ''
-- khách hàng
EXEC sp_AddAcc '', '', N'Khách hàng', N'Lê Thị Linh', '12-4-2001', N'nữ', 'lethilinh@gmail.com', '0938252524', ''
EXEC sp_AddAcc '', '', N'Khách hàng', N'Hồ Minh Ngọc', '12-3-2001', N'nam', 'hominhngoc@gmail.com', '0935252528', ''
EXEC sp_AddAcc '', '', N'Khách hàng', N'Lý Gia Huy', '2-13-2001', N'nam', 'lygiahuy@gmail.com', '0937151518', ''
EXEC sp_AddAcc '', '', N'Khách hàng', N'Nguyễn Thị Thương', '4-13-2001', N'Nữ', 'thuongnguyen@gmail.com', '0935262628', ''
EXEC sp_AddAcc '', '', N'Khách hàng', N'Trần Ngọc Sang', '3-30-2001', N'nam', 'sangtran@gmail.com', '0915236268', ''
EXEC sp_AddAcc '', '', N'Khách hàng', N'Huỳnh Ái Linh', '7-24-2001', N'Nữ', 'linh247@gmail.com', '0926352528', ''
EXEC sp_AddAcc '', '', N'Khách hàng', N'Đỗ Ái Vy', '11-4-2001', N'nữ', 'vydo@gmail.com', '0925362624', ''
EXEC sp_AddAcc '', '', N'Khách hàng', N'Cao Gia Vinh', '12-3-2001', N'nữ', 'vinh123@gmail.com', '0932562315', ''
EXEC sp_AddAcc '', '', N'Khách hàng', N'Lê Hồng Đào', '2-13-2001', N'Nữ', 'daole132@gmail.com', '0925216358', ''
EXEC sp_AddAcc '', '', N'Khách hàng', N'Nguyễn Văn Cao', '4-13-2001', N'nam', 'caonguyen134@gmail.com', '0935626248', ''
EXEC sp_AddAcc '', '', N'Khách hàng', N'Từ Huệ Sơn', '2-5-2001', N'nam', 'tuhueson@gmail.com', '0938252793', ''

-- BẢNG DANH MỤC
INSERT DANHMUC SELECT N'Điện Thoại'
INSERT DANHMUC SELECT N'Phụ kiện'

-- BẢNG LOẠI SẢN PHẨM
EXEC sp_AddLSP N'Android', N'Điện Thoại'
EXEC sp_AddLSP N'iPhone(iOS)', N'Điện Thoại'
EXEC sp_AddLSP N'Điện thoại phổ thông', N'Điện Thoại'
-- phụ kiện
EXEC sp_AddLSP N'Pin sạc dự phòng', N'Phụ kiện'
EXEC sp_AddLSP N'Sạc, cáp', N'Phụ kiện'
EXEC sp_AddLSP N'Miếng dán màn hình', N'Phụ kiện'
EXEC sp_AddLSP N'Ốp lưng điện thoại', N'Phụ kiện'
EXEC sp_AddLSP N'Gậy tự sướng', N'Phụ kiện'
EXEC sp_AddLSP N'Đế móc điện thoại', N'Phụ kiện'
EXEC sp_AddLSP N'Túi chống nước', N'Phụ kiện'

-- BẢNG HÃNG SP
INSERT HANG (TENHANG) SELECT N'iPhone'
INSERT HANG (TENHANG) SELECT N'SAMSUNG'
INSERT HANG (TENHANG) SELECT N'OPPO'
INSERT HANG (TENHANG) SELECT N'VIVO'
INSERT HANG (TENHANG) SELECT N'XIAOMI'
INSERT HANG (TENHANG) SELECT N'REALME'
INSERT HANG (TENHANG) SELECT N'NOKIA'
INSERT HANG (TENHANG) SELECT N'MOBELL'
INSERT HANG (TENHANG) SELECT N'INTEL'
INSERT HANG (TENHANG) SELECT N'MASSTEL'
INSERT HANG (TENHANG) SELECT N'Energizer'

-- BẢNG SẢN PHẨM
EXEC sp_AddSP N'iPhone 12 64GB', N'iPhone', 50, 20490000, null, 'iPhone12_64.jpg', N'iPhone(iOS)' --
EXEC sp_AddSP N'iPhone 13 Pro Max 1TB', N'iPhone', 50, 49990000, null, 'iPhone13ProMax_1.jpg', N'iPhone(iOS)' --
EXEC sp_AddSP N'iPhone 13 Pro 1TB', N'iPhone', 50, 46990000, null, 'iPhone13Pro_1.jpg', N'iPhone(iOS)' --
EXEC sp_AddSP N'iPhone 13 Pro Max 512GB', N'iPhone', 50, 43990000, null, 'iPhone13ProMax_512.jpg', N'iPhone(iOS)' --
EXEC sp_AddSP N'iPhone 13 Pro 512GB', N'iPhone', 50, 40990000, null, 'iPhone13Pro_512.jpg', N'iPhone(iOS)' --
EXEC sp_AddSP N'iPhone 12 Pro Max 512GB', N'iPhone', 50, 39990000, null, 'iPhone12Pro_512.jpg', N'iPhone(iOS)' --
EXEC sp_AddSP N'iPhone 13 mini 256GB', N'iPhone', 50, 24990000, null, 'iPhone13Mini_256.jpg', N'iPhone(iOS)' --
EXEC sp_AddSP N'iPhone 11 128GB', N'iPhone', 50, 18990000, null, 'iPhone11_128.jpg', N'iPhone(iOS)' --
EXEC sp_AddSP N'iPhone XR 128GB', N'iPhone', 50, 16490000, null, 'iPhoneXR_128.jpg', N'iPhone(iOS)' --
EXEC sp_AddSP N'Samsung Galaxy Z Fold3 5G 512GB', N'SAMSUNG', 50, 43990000, null, 'samsungGalaxyZFold3_512.jpg', N'Android'
EXEC sp_AddSP N'Samsung Galaxy A03s', N'SAMSUNG', 50, 3690000, null, 'samsungGalaxyA03s.jpg', N'Android'
EXEC sp_AddSP N'Samsung Galaxy M51', N'SAMSUNG', 50, 9490000, null, 'samsungGalaxyM51.jpg', N'Android'
EXEC sp_AddSP N'Samsung Galaxy Z Flip3 5G 256GB', N'SAMSUNG', 50, 25990000, null, 'samsungGalaxyZFlip3_256.jpg', N'Android'
EXEC sp_AddSP N'OPPO Reno6 Z 5G', N'OPPO', 50, 9490000, null, 'oppoReno6Z.jpg', N'Android'
EXEC sp_AddSP N'OPPO A74', N'OPPO', 50, 6690000, null, 'oppoA74.jpg', N'Android'
EXEC sp_AddSP N'OPPO A55', N'OPPO', 50, 4990000, null, 'oppoA55.jpg', N'Android'
EXEC sp_AddSP N'OPPO Reno5 Marvel', N'OPPO', 50, 9190000, null, 'oppoReno5Marvel.jpg', N'Android'
EXEC sp_AddSP N'Vivo Y21', N'VIVO', 50, 4290000, null, 'vivoY21.jpg', N'Android'
EXEC sp_AddSP N'Vivo X70 Pro 5G', N'VIVO', 50, 18990000, null, 'vivoX70Pro.jpg', N'Android'
EXEC sp_AddSP N'Vivo Y72 5G', N'VIVO', 50, 7590000, null, 'vivoY72.jpg', N'Android'
EXEC sp_AddSP N'Vivo V20 SE', N'VIVO', 50, 6490000, null, 'vivoV20SE.jpg', N'Android'
EXEC sp_AddSP N'Xiaomi 11T 5G 256GB', N'XIAOMI', 50, 11990000, null, 'xiaomi11T_256.jpg', N'Android'
EXEC sp_AddSP N'Xiaomi 11 Lite 5G NE', N'XIAOMI', 50, 9490000, null, 'xiaomi11Lite.jpg', N'Android'
EXEC sp_AddSP N'Xiaomi Redmi Note 10S', N'XIAOMI', 50, 6490000, null, 'xiaomiRedmiNote10s.jpg', N'Android'
EXEC sp_AddSP N'Xiaomi Redmi Note 9', N'XIAOMI', 50, 4490000, null, 'xiaomiRedmiNote9.jpg', N'Android'
EXEC sp_AddSP N'Realme C21Y 4GB', N'REALME', 50, 3990000, null, 'realmeC21Y.jpg', N'Android'
EXEC sp_AddSP N'Realme 7 Pro', N'REALME', 50, 8540000, null, 'realme7Pro.jpg', N'Android'
EXEC sp_AddSP N'Realme 8 Pro Vàng Rực Rỡ', N'REALME', 50, 8240000, null, 'realme8ProVang.jpg', N'Android'
EXEC sp_AddSP N'Realme 6 Pro', N'REALME', 50, 6990000, null, 'realme6Pro.jpg', N'Android'
EXEC sp_AddSP N'Nokia 3.4', N'NOKIA', 50, 3290000, null, 'nokia34Android.jpg', N'Android'
EXEC sp_AddSP N'Nokia C30', N'NOKIA', 50, 2790000, null, 'nokiaC30.jpg', N'Android'
EXEC sp_AddSP N'Nokia 210', N'NOKIA', 50, 790000, null, 'nokia210.jpg', N'Điện thoại phổ thông'
EXEC sp_AddSP N'Nokia 6300 4G', N'NOKIA', 50, 1090000, null, 'nokia6300.jpg', N'Điện thoại phổ thông'
EXEC sp_AddSP N'Mobell P41', N'MOBELL', 50, 990000, null, 'mobellP41.jpg', N'Android'
EXEC sp_AddSP N'Mobell Rock 3', N'MOBELL', 50, 590000, null, 'mobellRock3.jpg', N'Điện thoại phổ thông'
EXEC sp_AddSP N'Mobell C310', N'MOBELL', 50, 230000, null, 'mobellC310.jpg', N'Điện thoại phổ thông'
EXEC sp_AddSP N'Mobell M729', N'MOBELL', 50, 450000, null, 'mobellM729.jpg', N'Điện thoại phổ thông'
EXEC sp_AddSP N'Itel L6006', N'INTEL', 50, 2190000, null, 'itelL6006.jpg', N'Android'
EXEC sp_AddSP N'Itel it9200 4G', N'INTEL', 50, 700000, null, 'itelIt9200.jpg', N'Điện thoại phổ thông'
EXEC sp_AddSP N'Itel it2590', N'INTEL', 50, 450000, null, 'itelIt2590.jpg', N'Điện thoại phổ thông'
EXEC sp_AddSP N'Itel it5071', N'INTEL', 50, 330000, null, 'itelIt5071.jpg', N'Điện thoại phổ thông'
EXEC sp_AddSP N'Masstel Fami P20', N'MASSTEL', 50, 550000, null, 'masstelFamiP20.jpg', N'Điện thoại phổ thông'
EXEC sp_AddSP N'Masstel Play 50', N'MASSTEL', 50, 500000, null, 'masstelPlay50.jpg', N'Điện thoại phổ thông'
EXEC sp_AddSP N'Masstel IZI 300', N'MASSTEL', 50, 450000, null, 'masstelIzi300.jpg', N'Điện thoại phổ thông'
EXEC sp_AddSP N'Masstel IZI 230', N'MASSTEL', 50, 380000, null, 'masstelIzi230.jpg', N'Điện thoại phổ thông'
EXEC sp_AddSP N'Energizer E241S', N'Energizer', 50, 890000, null, 'energizerE241s.jpg', N'Điện thoại phổ thông'
EXEC sp_AddSP N'Energizer E20', N'Energizer', 50, 650000, null, 'energizerE20.jpg', N'Điện thoại phổ thông'
EXEC sp_AddSP N'Energizer P20', N'Energizer', 50, 590000, null, 'energizerP20.jpg', N'Điện thoại phổ thông'
EXEC sp_AddSP N'Energizer E100', N'Energizer', 50, 490000, null, 'energizerE100.jpg', N'Điện thoại phổ thông'

--SẠC DỰ PHÒNG
EXEC sp_AddSP N'Pin sạc dự phòng Polymer 10.000 mAh Type C Xiaomi Power Bank 3 Ultra Compact', N'XIAOMI', 50, 474000, N'Trung Quốc', 'polymerXiaomiUltraCompact.jpg', N'Pin sạc dự phòng'
EXEC sp_AddSP N'Pin sạc dự phòng Polymer 10.000mAh Type C Fast Charge Xiaomi Mi Power Bank 3', N'XIAOMI', 50, 374000, N'Trung Quốc', 'pinsacduphongpolymer.jpg', N'Pin sạc dự phòng'
EXEC sp_AddSP N'Pin sạc dự phòng Polymer 10.000 mAh Type C PD Samsung EB-P3300', N'SAMSUNG', 50, 693000, N'Trung Quốc', 'polymersamsungebP3300.jpg', N'Pin sạc dự phòng'
EXEC sp_AddSP N'Pin sạc dự phòng Polymer 20.000 mAh Type C PD Energizer UE20011PQ', N'Energizer', 50, 770000, N'Trung Quốc', 'energizerfix2.jpg', N'Pin sạc dự phòng'

--Sạc, cáp
EXEC sp_AddSP N'Adapter Sạc Type C PD 25W Samsung EP-TA800N', N'SAMSUNG', 50, 490000, N'Việt Nam', 'type-c-pdsamsungTa800n.jpg', N'Sạc, cáp'
EXEC sp_AddSP N'Cáp chuyển đổi Type C sang 3.5mm Samsung EE-UC10JUW Trắng', N'SAMSUNG', 50, 220000, N'Việt Nam', 'capChuyenDoisamsungeeUc10juw.jpg', N'Sạc, cáp'
EXEC sp_AddSP N'Cáp Type-C 1.2 m Energizer C41C2AGBKT Đen', N'Energizer', 50, 175000, N'Trung Quốc', 'captypecEnergizec41c2agbkt.jpg', N'Sạc, cáp'
EXEC sp_AddSP N'Sạc không dây xe hơi 20W Xiaomi GDS4127GL Đen', N'XIAOMI', 50, 774000, N'Trung Quốc', 'sacKhongDayXiaomiGds4127gl.jpg', N'Sạc, cáp'

--Miếng dán màn hình
EXEC sp_AddSP N'Miếng dán màn hình iPhone 13 Pro Max', N'iPhone', 50, 50000, null, '.jpg', N'Miếng dán màn hình'
EXEC sp_AddSP N'Miếng dán kính iPhone 13 Pro Max JCPAL', N'iPhone', 50, 390000, null, '.jpg', N'Miếng dán màn hình'
EXEC sp_AddSP N'Miếng dán full màn hình TA SHT31 Galaxy S21 Ultra', N'SAMSUNG', 50, 100000, null, '.jpg', N'Miếng dán màn hình'
EXEC sp_AddSP N'Miếng dán màn hình Galaxy S21', N'SAMSUNG', 50, 50000, null, '.jpg', N'Miếng dán màn hình'

--Ốp lưng điện thoại
EXEC sp_AddSP N'Ốp lưng iPhone 13 Silicon OSMIA Cam', null, 50, 70000, null, 'oplungiphone13cam.jpg', N'Ốp lưng điện thoại'
EXEC sp_AddSP N'Ốp lưng iPhone 13 Pro Max Nhựa cứng viền dẻo Magnets KingxBar Trắng', null, 50, 245000, null, 'iphone13proMaxNhuaCung.jpg', N'Ốp lưng điện thoại'
EXEC sp_AddSP N'Ốp lưng Galaxy A71 nhựa dẻo Woven OSMIA Xanh Đậm', null, 50, 49000, null, 'oplunggalaxya71XanhDam.jpg', N'Ốp lưng điện thoại'
EXEC sp_AddSP N'Ốp lưng Galaxy A71 nhựa dẻo TPU Electroplating Triple COSANO Bạc', null, 50, 70000, null, 'oplunggalaxy-a71nhuadeo.jpg', N'Ốp lưng điện thoại'

--Gậy tự sướng
EXEC sp_AddSP N'Gậy chụp ảnh Bluetooth Tripod Xmobile K06 Đen', null, 50, 240000, null, 'gayChupAnhxmobileK06.jpg', N'Gậy tự sướng'
EXEC sp_AddSP N'Gậy Chụp Ảnh Bluetooth Cosano HD-P7', null, 50, 120000, null, 'gayChupAnhCosanoP7.jpg', N'Gậy tự sướng'
EXEC sp_AddSP N'Gậy Chụp Ảnh Xmobile Hình Cô gái CSA005', null, 50, 72000, null, 'gayChupAnhCoGaiHong.jpg', N'Gậy tự sướng'
EXEC sp_AddSP N'Gậy Chụp Ảnh Osmia OW5', null, 50, 70000, null, 'gayChupAnhOw5.jpg', N'Gậy tự sướng'

--Đế móc điện thoại
EXEC sp_AddSP N'Dây đeo điện thoại OSMIA silicon CRS', null, 50, 24000, null, '.jpg', N'Đế móc điện thoại'
EXEC sp_AddSP N'Bộ 2 móc điện thoại OSMIA CK-CRS10 Mèo cá heo xanh', null, 50, 48000, null, '.jpg', N'Đế móc điện thoại'
EXEC sp_AddSP N'Bộ 2 móc điện thoại OSMIA CK-CRS11 Hươu cánh cụt vàng', null, 50, 48000, null, '.jpg', N'Đế móc điện thoại'
EXEC sp_AddSP N'Bộ 2 móc điện thoại nhựa dẻo OSMIA CK-CRS3 Nai Mèo Đen', null, 50, 32000, null, '.jpg', N'Đế móc điện thoại'

--Túi chống nước
EXEC sp_AddSP N'Túi chống nước Cosano JMG-C-20 Xanh lá', null, 50, 40000, null, '.jpg', N'Túi chống nước'
EXEC sp_AddSP N'Túi chống nước Cosano JMG-C-21 Xanh biển', null, 50, 40000, null, '.jpg', N'Túi chống nước'
EXEC sp_AddSP N'Túi chống nước Cosano 5 inch Vàng Chanh', null, 50, 40000, null, '.jpg', N'Túi chống nước'
EXEC sp_AddSP N'Túi chống nước 5 inch Cosano Hình Chú mèo', null, 50, 40000, null, '.jpg', N'Túi chống nước'

-- Bảng cấu hình(thông tin sản phẩm)
EXEC sp_AddCauHinh N'Energizer E100', N'Màn hình', N'TFT LCD, 2.4", 65.536 màu'
EXEC sp_AddCauHinh N'Energizer E100', N'Camera sau', N'0.3 MP'
EXEC sp_AddCauHinh N'Energizer E100', N'SIM', N'2 SIM thường, Hỗ trợ 4G'
EXEC sp_AddCauHinh N'Energizer E100', N'Pin', N'1500 mAh'
EXEC sp_AddCauHinh N'Energizer E100', N'Danh bạ', N'300 số'
EXEC sp_AddCauHinh N'Energizer E100', N'Thẻ nhớ', N'MicroSD, hỗ trợ tối đa 16 GB'
EXEC sp_AddCauHinh N'Energizer E100', N'Radio FM', N'Có'
EXEC sp_AddCauHinh N'Energizer E100', N'Jack cắm tai nghe', N'3.5 mm'

EXEC sp_AddCauHinh N'Energizer E20', N'Màn hình', N'TFT LCD, 2.8", 262.144 màu'
EXEC sp_AddCauHinh N'Energizer E20', N'Camera sau', N'0.3 MP'
EXEC sp_AddCauHinh N'Energizer E20', N'SIM', N'2 SIM thường, Hỗ trợ 4G'
EXEC sp_AddCauHinh N'Energizer E20', N'Pin', N'1000 mAh'
EXEC sp_AddCauHinh N'Energizer E20', N'Danh bạ', N'300 số'
EXEC sp_AddCauHinh N'Energizer E20', N'Thẻ nhớ', N'MicroSD, hỗ trợ tối đa 16 GB'
EXEC sp_AddCauHinh N'Energizer E20', N'Radio FM', N'Có'
EXEC sp_AddCauHinh N'Energizer E20', N'Jack cắm tai nghe', N'3.5 mm'

EXEC sp_AddCauHinh N'Energizer P20', N'Màn hình', N'TFT LCD, 2.8", 262.144 màu'
EXEC sp_AddCauHinh N'Energizer P20', N'Camera sau', N'0.3 MP'
EXEC sp_AddCauHinh N'Energizer P20', N'SIM', N'2 SIM thường, Hỗ trợ 4G'
EXEC sp_AddCauHinh N'Energizer P20', N'Pin', N'4000 mAh'
EXEC sp_AddCauHinh N'Energizer P20', N'Danh bạ', N'300 số'
EXEC sp_AddCauHinh N'Energizer P20', N'Thẻ nhớ', N'MicroSD, hỗ trợ tối đa 16 GB'
EXEC sp_AddCauHinh N'Energizer P20', N'Radio FM', N'Có'
EXEC sp_AddCauHinh N'Energizer P20', N'Jack cắm tai nghe', N'3.5 mm'

EXEC sp_AddCauHinh N'Energizer E241S', N'Màn hình', N'TFT LCD, 2.4", 16 triệu màu'
EXEC sp_AddCauHinh N'Energizer E241S', N'Camera sau', N'QVGA (320 x 240 pixels)'
EXEC sp_AddCauHinh N'Energizer E241S', N'Camera trước', N'VGA (0.3 MP)'
EXEC sp_AddCauHinh N'Energizer E241S', N'SIM', N'2 Micro SIM, Hỗ trợ 4G'
EXEC sp_AddCauHinh N'Energizer E241S', N'Pin', N'1900 mAh'
EXEC sp_AddCauHinh N'Energizer E241S', N'Danh bạ', N'300 số'
EXEC sp_AddCauHinh N'Energizer E241S', N'Thẻ nhớ', N'MicroSD, hỗ trợ tối đa 32 GB'
EXEC sp_AddCauHinh N'Energizer E241S', N'Radio FM', N'Có'
EXEC sp_AddCauHinh N'Energizer E241S', N'Jack cắm tai nghe', N'3.5 mm'

EXEC sp_AddCauHinh N'Masstel IZI 230', N'Màn hình', N'TFT LCD, 2.4", 262.144 màu'
EXEC sp_AddCauHinh N'Masstel IZI 230', N'Camera sau', N'0.08 MP'
EXEC sp_AddCauHinh N'Masstel IZI 230', N'SIM', N'2 SIM thường, Hỗ trợ 2G'
EXEC sp_AddCauHinh N'Masstel IZI 230', N'Pin', N'1700 mAh'
EXEC sp_AddCauHinh N'Masstel IZI 230', N'Danh bạ', N'300 số'
EXEC sp_AddCauHinh N'Masstel IZI 230', N'Thẻ nhớ', N'MicroSD, hỗ trợ tối đa 16 GB'
EXEC sp_AddCauHinh N'Masstel IZI 230', N'Radio FM', N'FM không cần tai nghe'
EXEC sp_AddCauHinh N'Masstel IZI 230', N'Jack cắm tai nghe', N'3.5 mm'

EXEC sp_AddCauHinh N'Masstel IZI 300', N'Màn hình', N'TFT LCD, 2.4", 65.536 màu'
EXEC sp_AddCauHinh N'Masstel IZI 300', N'Camera sau', N'0.08 MP'
EXEC sp_AddCauHinh N'Masstel IZI 300', N'SIM', N'1 Micro SIM & 1 SIM thường, Hỗ trợ 2G'
EXEC sp_AddCauHinh N'Masstel IZI 300', N'Pin', N'2500 mAh'
EXEC sp_AddCauHinh N'Masstel IZI 300', N'Danh bạ', N'300 số'
EXEC sp_AddCauHinh N'Masstel IZI 300', N'Thẻ nhớ', N'MicroSD, hỗ trợ tối đa 16 GB'
EXEC sp_AddCauHinh N'Masstel IZI 300', N'Radio FM', N'Có'
EXEC sp_AddCauHinh N'Masstel IZI 300', N'Jack cắm tai nghe', N'3.5 mm'

EXEC sp_AddCauHinh N'Masstel Play 50', N'Màn hình', N'TFT LCD, 2.4", 256.000 màu'
EXEC sp_AddCauHinh N'Masstel Play 50', N'Camera sau', N'0.08 MP'
EXEC sp_AddCauHinh N'Masstel Play 50', N'SIM', N'2 SIM thường, Hỗ trợ 2G'
EXEC sp_AddCauHinh N'Masstel Play 50', N'Pin', N'3000 mAh'
EXEC sp_AddCauHinh N'Masstel Play 50', N'Danh bạ', N'1000 số'
EXEC sp_AddCauHinh N'Masstel Play 50', N'Thẻ nhớ', N'MicroSD, hỗ trợ tối đa 32 GB'
EXEC sp_AddCauHinh N'Masstel Play 50', N'Radio FM', N'FM không cần tai nghe'
EXEC sp_AddCauHinh N'Masstel Play 50', N'Jack cắm tai nghe', N'3.5 mm'

EXEC sp_AddCauHinh N'Masstel Fami P20', N'Màn hình', N'TFT LCD, 2.2", 262.144 màu'
EXEC sp_AddCauHinh N'Masstel Fami P20', N'Camera sau', N'0.08 MP'
EXEC sp_AddCauHinh N'Masstel Fami P20', N'SIM', N'2 SIM thường, Hỗ trợ 2G'
EXEC sp_AddCauHinh N'Masstel Fami P20', N'Pin', N'1400 mAh'
EXEC sp_AddCauHinh N'Masstel Fami P20', N'Danh bạ', N'300 số'
EXEC sp_AddCauHinh N'Masstel Fami P20', N'Thẻ nhớ', N'MicroSD, hỗ trợ tối đa 16 GB'
EXEC sp_AddCauHinh N'Masstel Fami P20', N'Radio FM', N'Có'
EXEC sp_AddCauHinh N'Masstel Fami P20', N'Jack cắm tai nghe', N'3.5 mm'

EXEC sp_AddCauHinh N'Itel it5071', N'Màn hình', N'TFT LCD, 2.4", 65.536 màu'
EXEC sp_AddCauHinh N'Itel it5071', N'Camera sau', N'0.08 MP'
EXEC sp_AddCauHinh N'Itel it5071', N'SIM', N'2 SIM thường, Hỗ trợ 2G'
EXEC sp_AddCauHinh N'Itel it5071', N'Pin', N'1900 mAh'
EXEC sp_AddCauHinh N'Itel it5071', N'Danh bạ', N'500 số'
EXEC sp_AddCauHinh N'Itel it5071', N'Thẻ nhớ', N'MicroSD, hỗ trợ tối đa 16 GB'
EXEC sp_AddCauHinh N'Itel it5071', N'Radio FM', N'FM không cần tai nghe'
EXEC sp_AddCauHinh N'Itel it5071', N'Jack cắm tai nghe', N'3.5 mm'

EXEC sp_AddCauHinh N'Itel it2590', N'Màn hình', N'TFT LCD, 2.2", 65.536 màu'
EXEC sp_AddCauHinh N'Itel it2590', N'Camera sau', N'0.3 MP'
EXEC sp_AddCauHinh N'Itel it2590', N'SIM', N'2 Micro SIM, Hỗ trợ 2G'
EXEC sp_AddCauHinh N'Itel it2590', N'Pin', N'1900 mAh'
EXEC sp_AddCauHinh N'Itel it2590', N'Danh bạ', N'500 số'
EXEC sp_AddCauHinh N'Itel it2590', N'Thẻ nhớ', N'MicroSD, hỗ trợ tối đa 32 GB'
EXEC sp_AddCauHinh N'Itel it2590', N'Radio FM', N'Có'
EXEC sp_AddCauHinh N'Itel it2590', N'Jack cắm tai nghe', N'3.5 mm'

EXEC sp_AddCauHinh N'Itel it9200 4G', N'Màn hình', N'TFT LCD, 2.4", 262.000 màu'
EXEC sp_AddCauHinh N'Itel it9200 4G', N'Camera sau', N'0.3 MP'
EXEC sp_AddCauHinh N'Itel it9200 4G', N'Camera trước', N'VGA (0.3 MP)'
EXEC sp_AddCauHinh N'Itel it9200 4G', N'SIM', N'2 Micro SIM, Hỗ trợ 4G'
EXEC sp_AddCauHinh N'Itel it9200 4G', N'Pin', N'1900 mAh'
EXEC sp_AddCauHinh N'Itel it9200 4G', N'Danh bạ', N'Không giới hạn'
EXEC sp_AddCauHinh N'Itel it9200 4G', N'Thẻ nhớ', N'MicroSD, hỗ trợ tối đa 128 GB'
EXEC sp_AddCauHinh N'Itel it9200 4G', N'Radio FM', N'Có'
EXEC sp_AddCauHinh N'Itel it9200 4G', N'Jack cắm tai nghe', N'3.5 mm'

EXEC sp_AddCauHinh N'Itel L6006', N'Màn hình', N'IPS LCD, 6.1", HD+'
EXEC sp_AddCauHinh N'Itel L6006', N'Hệ điều hành', N'Android 10 (Go Edition)'
EXEC sp_AddCauHinh N'Itel L6006', N'Camera sau', N'Chính 5 MP & Phụ VGA'
EXEC sp_AddCauHinh N'Itel L6006', N'Camera trước', N'5 MP'
EXEC sp_AddCauHinh N'Itel L6006', N'Chip', N'Spreadtrum SC9832E'
EXEC sp_AddCauHinh N'Itel L6006', N'RAM', N'2 GB'
EXEC sp_AddCauHinh N'Itel L6006', N'Bộ nhớ trong', N'32 GB'
EXEC sp_AddCauHinh N'Itel L6006', N'SIM', N'2 Micro SIM, Hỗ trợ 4G'
EXEC sp_AddCauHinh N'Itel L6006', N'Pin, Sạc', N'3000 mAh, 5 W'

EXEC sp_AddCauHinh N'Mobell M729', N'Màn hình', N'TFT LCD, 2.4", 65.536 màu'
EXEC sp_AddCauHinh N'Mobell M729', N'Camera sau', N'0.3 MP'
EXEC sp_AddCauHinh N'Mobell M729', N'SIM', N'2 SIM thường, Hỗ trợ 2G'
EXEC sp_AddCauHinh N'Mobell M729', N'Pin', N'1000 mAh'
EXEC sp_AddCauHinh N'Mobell M729', N'Danh bạ', N'300 số'
EXEC sp_AddCauHinh N'Mobell M729', N'Thẻ nhớ', N'MicroSD, hỗ trợ tối đa 16 GB'
EXEC sp_AddCauHinh N'Mobell M729', N'Radio FM', N'Có'
EXEC sp_AddCauHinh N'Mobell M729', N'Jack cắm tai nghe', N'Micro USB'

EXEC sp_AddCauHinh N'Mobell C310', N'Màn hình', N'TFT LCD, 1.77", 262.000 màu'
EXEC sp_AddCauHinh N'Mobell C310', N'Camera sau', N'0.8 MP'
EXEC sp_AddCauHinh N'Mobell C310', N'SIM', N'2 SIM thường, Hỗ trợ 2G'
EXEC sp_AddCauHinh N'Mobell C310', N'Pin', N'800 mAh'
EXEC sp_AddCauHinh N'Mobell C310', N'Danh bạ', N'500 số'
EXEC sp_AddCauHinh N'Mobell C310', N'Thẻ nhớ', N'MicroSD, hỗ trợ tối đa 32 GB'
EXEC sp_AddCauHinh N'Mobell C310', N'Radio FM', N'Có'
EXEC sp_AddCauHinh N'Mobell C310', N'Jack cắm tai nghe', N'3.5 mm'

EXEC sp_AddCauHinh N'Mobell Rock 3', N'Màn hình', N'TFT LCD, 2.4", 65.536 màu'
EXEC sp_AddCauHinh N'Mobell Rock 3', N'Camera sau', N'0.08 MP'
EXEC sp_AddCauHinh N'Mobell Rock 3', N'SIM', N'1 Micro SIM & 1 SIM thường, Hỗ trợ 2G'
EXEC sp_AddCauHinh N'Mobell Rock 3', N'Pin', N'5000 mAh'
EXEC sp_AddCauHinh N'Mobell Rock 3', N'Danh bạ', N'200 số'
EXEC sp_AddCauHinh N'Mobell Rock 3', N'Thẻ nhớ', N'MicroSD, hỗ trợ tối đa 8 GB'
EXEC sp_AddCauHinh N'Mobell Rock 3', N'Radio FM', N'Có'
EXEC sp_AddCauHinh N'Mobell Rock 3', N'Jack cắm tai nghe', N'Micro USB'

EXEC sp_AddCauHinh N'Mobell P41', N'Màn hình', N'IPS LCD, 5.5", FWVGA+'
EXEC sp_AddCauHinh N'Mobell P41', N'Hệ điều hành', N'Android 8 (Oreo)'
EXEC sp_AddCauHinh N'Mobell P41', N'Camera sau', N'5 MP'
EXEC sp_AddCauHinh N'Mobell P41', N'Camera trước', N'2 MP'
EXEC sp_AddCauHinh N'Mobell P41', N'Chip', N'MediaTek MT6580A'
EXEC sp_AddCauHinh N'Mobell P41', N'RAM', N'1 GB'
EXEC sp_AddCauHinh N'Mobell P41', N'Bộ nhớ trong', N'8 GB'
EXEC sp_AddCauHinh N'Mobell P41', N'SIM', N'2 Nano SIM, Hỗ trợ 3G'
EXEC sp_AddCauHinh N'Mobell P41', N'Pin, Sạc', N'3500 mAh, 5 W'

EXEC sp_AddCauHinh N'Nokia 6300 4G', N'Màn hình', N'TFT LCD, 2.4", 16 triệu màu'
EXEC sp_AddCauHinh N'Nokia 6300 4G', N'Camera sau', N'VGA (480 x 640 pixels)'
EXEC sp_AddCauHinh N'Nokia 6300 4G', N'SIM', N'2 Nano SIM, Hỗ trợ 4G'
EXEC sp_AddCauHinh N'Nokia 6300 4G', N'Pin', N'1500 mAh'
EXEC sp_AddCauHinh N'Nokia 6300 4G', N'Danh bạ', N'1500 số'
EXEC sp_AddCauHinh N'Nokia 6300 4G', N'Thẻ nhớ', N'MicroSD, hỗ trợ tối đa 32 GB'
EXEC sp_AddCauHinh N'Nokia 6300 4G', N'Radio FM', N'Có'
EXEC sp_AddCauHinh N'Nokia 6300 4G', N'Jack cắm tai nghe', N'3.5 mm'

EXEC sp_AddCauHinh N'Nokia 210', N'Màn hình', N'TFT LCD, 2.4", 65.536 màu'
EXEC sp_AddCauHinh N'Nokia 210', N'Camera sau', N'0.3 MP'
EXEC sp_AddCauHinh N'Nokia 210', N'SIM', N'2 SIM thường, Hỗ trợ 2G'
EXEC sp_AddCauHinh N'Nokia 210', N'Pin', N'1020 mAh'
EXEC sp_AddCauHinh N'Nokia 210', N'Danh bạ', N'500 số'
EXEC sp_AddCauHinh N'Nokia 210', N'Thẻ nhớ', N'MicroSD, hỗ trợ tối đa 32 GB'
EXEC sp_AddCauHinh N'Nokia 210', N'Radio FM', N'Có'
EXEC sp_AddCauHinh N'Nokia 210', N'Jack cắm tai nghe', N'3.5 mm'

EXEC sp_AddCauHinh N'Nokia C30', N'Màn hình', N'IPS LCD, 6.82", HD+'
EXEC sp_AddCauHinh N'Nokia C30', N'Hệ điều hành', N'Android 11 (Go Edition)'
EXEC sp_AddCauHinh N'Nokia C30', N'Camera sau', N'Chính 13 MP & Phụ 2 MP'
EXEC sp_AddCauHinh N'Nokia C30', N'Camera trước', N'5 MP'
EXEC sp_AddCauHinh N'Nokia C30', N'Chip', N'Spreadtrum SC9863A'
EXEC sp_AddCauHinh N'Nokia C30', N'RAM', N'3 GB'
EXEC sp_AddCauHinh N'Nokia C30', N'Bộ nhớ trong', N'32 GB'
EXEC sp_AddCauHinh N'Nokia C30', N'SIM', N'2 Nano SIM, Hỗ trợ 4G'
EXEC sp_AddCauHinh N'Nokia C30', N'Pin, Sạc', N'6000 mAh, 10 W'

EXEC sp_AddCauHinh N'Nokia 3.4', N'Màn hình', N'IPS LCD, 6.39", HD+'
EXEC sp_AddCauHinh N'Nokia 3.4', N'Hệ điều hành', N'Android 10 (Android One)'
EXEC sp_AddCauHinh N'Nokia 3.4', N'Camera sau', N'Chính 13 MP & Phụ 5 MP, 2 MP'
EXEC sp_AddCauHinh N'Nokia 3.4', N'Camera trước', N'8 MP'
EXEC sp_AddCauHinh N'Nokia 3.4', N'Chip', N'Snapdragon 460'
EXEC sp_AddCauHinh N'Nokia 3.4', N'RAM', N'4 GB'
EXEC sp_AddCauHinh N'Nokia 3.4', N'Bộ nhớ trong', N'64 GB'
EXEC sp_AddCauHinh N'Nokia 3.4', N'SIM', N'2 Nano SIM, Hỗ trợ 4G'
EXEC sp_AddCauHinh N'Nokia 3.4', N'Pin, Sạc', N'4000 mAh, 10 W'

EXEC sp_AddCauHinh N'Realme 6 Pro', N'Màn hình', N'IPS LCD, 6.6", Full HD+'
EXEC sp_AddCauHinh N'Realme 6 Pro', N'Hệ điều hành', N'Android 10'
EXEC sp_AddCauHinh N'Realme 6 Pro', N'Camera sau', N'Chính 64 MP & Phụ 12 MP, 8 MP, 2 MP'
EXEC sp_AddCauHinh N'Realme 6 Pro', N'Camera trước', N'Chính 16 MP & Phụ 8 MP'
EXEC sp_AddCauHinh N'Realme 6 Pro', N'Chip', N'Snapdragon 720G'
EXEC sp_AddCauHinh N'Realme 6 Pro', N'RAM', N'8 GB'
EXEC sp_AddCauHinh N'Realme 6 Pro', N'Bộ nhớ trong', N'128 GB'
EXEC sp_AddCauHinh N'Realme 6 Pro', N'SIM', N'2 Nano SIM, Hỗ trợ 4G'
EXEC sp_AddCauHinh N'Realme 6 Pro', N'Pin, Sạc', N'4300 mAh, 30 W'

EXEC sp_AddCauHinh N'Realme 8 Pro Vàng Rực Rỡ', N'Màn hình', N'Super AMOLED, 6.4", Full HD+'
EXEC sp_AddCauHinh N'Realme 8 Pro Vàng Rực Rỡ', N'Hệ điều hành', N'Android 11'
EXEC sp_AddCauHinh N'Realme 8 Pro Vàng Rực Rỡ', N'Camera sau', N'Chính 108 MP & Phụ 8 MP, 2 MP, 2 MP'
EXEC sp_AddCauHinh N'Realme 8 Pro Vàng Rực Rỡ', N'Camera trước', N'16 MP'
EXEC sp_AddCauHinh N'Realme 8 Pro Vàng Rực Rỡ', N'Chip', N'Snapdragon 720G'
EXEC sp_AddCauHinh N'Realme 8 Pro Vàng Rực Rỡ', N'RAM', N'8 GB'
EXEC sp_AddCauHinh N'Realme 8 Pro Vàng Rực Rỡ', N'Bộ nhớ trong', N'128 GB'
EXEC sp_AddCauHinh N'Realme 8 Pro Vàng Rực Rỡ', N'SIM', N'2 Nano SIM, Hỗ trợ 4G'
EXEC sp_AddCauHinh N'Realme 8 Pro Vàng Rực Rỡ', N'Pin, Sạc', N'4500 mAh, 50 W'

EXEC sp_AddCauHinh N'Realme 7 Pro', N'Màn hình', N'Super AMOLED, 6.4", Full HD+'
EXEC sp_AddCauHinh N'Realme 7 Pro', N'Hệ điều hành', N'Android 10'
EXEC sp_AddCauHinh N'Realme 7 Pro', N'Camera sau', N'Chính 64 MP & Phụ 8 MP, 2 MP, 2 MP'
EXEC sp_AddCauHinh N'Realme 7 Pro', N'Camera trước', N'32 MP'
EXEC sp_AddCauHinh N'Realme 7 Pro', N'Chip', N'Snapdragon 720G'
EXEC sp_AddCauHinh N'Realme 7 Pro', N'RAM', N'8 GB'
EXEC sp_AddCauHinh N'Realme 7 Pro', N'Bộ nhớ trong', N'128 GB'
EXEC sp_AddCauHinh N'Realme 7 Pro', N'SIM', N'2 Nano SIM, Hỗ trợ 4G'
EXEC sp_AddCauHinh N'Realme 7 Pro', N'Pin, Sạc', N'4500 mAh, 65 W'

EXEC sp_AddCauHinh N'Realme C21Y 4GB', N'Màn hình', N'IPS LCD, 6.5", HD+'
EXEC sp_AddCauHinh N'Realme C21Y 4GB', N'Hệ điều hành', N'Android 11'
EXEC sp_AddCauHinh N'Realme C21Y 4GB', N'Camera sau', N'Chính 13 MP & Phụ 2 MP, 2 MP'
EXEC sp_AddCauHinh N'Realme C21Y 4GB', N'Camera trước', N'5 MP'
EXEC sp_AddCauHinh N'Realme C21Y 4GB', N'Chip', N'Spreadtrum T610 8 nhân'
EXEC sp_AddCauHinh N'Realme C21Y 4GB', N'RAM', N'4 GB'
EXEC sp_AddCauHinh N'Realme C21Y 4GB', N'Bộ nhớ trong', N'64 GB'
EXEC sp_AddCauHinh N'Realme C21Y 4GB', N'SIM', N'2 Nano SIM, Hỗ trợ 4G'
EXEC sp_AddCauHinh N'Realme C21Y 4GB', N'Pin, Sạc', N'5000 mAh, 10 W'

EXEC sp_AddCauHinh N'iPhone 12 64GB', N'Màn hình', N'OLED, 6.1", Super Retina XDR'
EXEC sp_AddCauHinh N'iPhone 12 64GB', N'Hệ điều hành', N'iOS 14'
EXEC sp_AddCauHinh N'iPhone 12 64GB', N'Camera sau', N'2 camera 12 MP'
EXEC sp_AddCauHinh N'iPhone 12 64GB', N'Camera trước', N'12 MP'
EXEC sp_AddCauHinh N'iPhone 12 64GB', N'Chip', N'Apple A14 Bionic'
EXEC sp_AddCauHinh N'iPhone 12 64GB', N'RAM', N'4 GB'
EXEC sp_AddCauHinh N'iPhone 12 64GB', N'Bộ nhớ trong', N'64 GB'
EXEC sp_AddCauHinh N'iPhone 12 64GB', N'SIM', N'1 Nano SIM & 1 eSIM, Hỗ trợ 5G'
EXEC sp_AddCauHinh N'iPhone 12 64GB', N'Pin, Sạc', N'2815 mAh, 20 W'

EXEC sp_AddCauHinh N'iPhone 13 Pro Max 1TB', N'Màn hình', N'OLED, 6.7", Super Retina XDR'
EXEC sp_AddCauHinh N'iPhone 13 Pro Max 1TB', N'Hệ điều hành', N'iOS 15'
EXEC sp_AddCauHinh N'iPhone 13 Pro Max 1TB', N'Camera sau', N'3 camera 12 MP'
EXEC sp_AddCauHinh N'iPhone 13 Pro Max 1TB', N'Camera trước', N'12 MP'
EXEC sp_AddCauHinh N'iPhone 13 Pro Max 1TB', N'Chip', N'Apple A15 Bionic'
EXEC sp_AddCauHinh N'iPhone 13 Pro Max 1TB', N'RAM', N'6 GB'
EXEC sp_AddCauHinh N'iPhone 13 Pro Max 1TB', N'Bộ nhớ trong', N'1 TB'
EXEC sp_AddCauHinh N'iPhone 13 Pro Max 1TB', N'SIM', N'1 Nano SIM & 1 eSIM, Hỗ trợ 5G'
EXEC sp_AddCauHinh N'iPhone 13 Pro Max 1TB', N'Pin, Sạc', N'20 W'

EXEC sp_AddCauHinh N'iPhone 13 Pro 1TB', N'Màn hình', N'OLED, 6.1", Super Retina XDR'
EXEC sp_AddCauHinh N'iPhone 13 Pro 1TB', N'Hệ điều hành', N'iOS 15'
EXEC sp_AddCauHinh N'iPhone 13 Pro 1TB', N'Camera sau', N'3 camera 12 MP'
EXEC sp_AddCauHinh N'iPhone 13 Pro 1TB', N'Camera trước', N'12 MP'
EXEC sp_AddCauHinh N'iPhone 13 Pro 1TB', N'Chip', N'Apple A15 Bionic'
EXEC sp_AddCauHinh N'iPhone 13 Pro 1TB', N'RAM', N'6 GB'
EXEC sp_AddCauHinh N'iPhone 13 Pro 1TB', N'Bộ nhớ trong', N'1 TB'
EXEC sp_AddCauHinh N'iPhone 13 Pro 1TB', N'SIM', N'1 Nano SIM & 1 eSIM, Hỗ trợ 5G'
EXEC sp_AddCauHinh N'iPhone 13 Pro 1TB', N'Pin, Sạc', N'20 W'

EXEC sp_AddCauHinh N'iPhone 13 Pro Max 512GB', N'Màn hình', N'OLED, 6.7", Super Retina XDR'
EXEC sp_AddCauHinh N'iPhone 13 Pro Max 512GB', N'Hệ điều hành', N'iOS 15'
EXEC sp_AddCauHinh N'iPhone 13 Pro Max 512GB', N'Camera sau', N'3 camera 12 MP'
EXEC sp_AddCauHinh N'iPhone 13 Pro Max 512GB', N'Camera trước', N'12 MP'
EXEC sp_AddCauHinh N'iPhone 13 Pro Max 512GB', N'Chip', N'Apple A15 Bionic'
EXEC sp_AddCauHinh N'iPhone 13 Pro Max 512GB', N'RAM', N'6 GB'
EXEC sp_AddCauHinh N'iPhone 13 Pro Max 512GB', N'Bộ nhớ trong', N'512 GB'
EXEC sp_AddCauHinh N'iPhone 13 Pro Max 512GB', N'SIM', N'1 Nano SIM & 1 eSIM, Hỗ trợ 5G'
EXEC sp_AddCauHinh N'iPhone 13 Pro Max 512GB', N'Pin, Sạc', N'20 W'

EXEC sp_AddCauHinh N'iPhone 13 Pro 512GB', N'Màn hình', N'OLED, 6.1", Super Retina XDR'
EXEC sp_AddCauHinh N'iPhone 13 Pro 512GB', N'Hệ điều hành', N'iOS 15'
EXEC sp_AddCauHinh N'iPhone 13 Pro 512GB', N'Camera sau', N'3 camera 12 MP'
EXEC sp_AddCauHinh N'iPhone 13 Pro 512GB', N'Camera trước', N'12 MP'
EXEC sp_AddCauHinh N'iPhone 13 Pro 512GB', N'Chip', N'Apple A15 Bionic'
EXEC sp_AddCauHinh N'iPhone 13 Pro 512GB', N'RAM', N'6 GB'
EXEC sp_AddCauHinh N'iPhone 13 Pro 512GB', N'Bộ nhớ trong', N'512 GB'
EXEC sp_AddCauHinh N'iPhone 13 Pro 512GB', N'SIM', N'1 Nano SIM & 1 eSIM, Hỗ trợ 5G'
EXEC sp_AddCauHinh N'iPhone 13 Pro 512GB', N'Pin, Sạc', N'20 W'

EXEC sp_AddCauHinh N'iPhone 12 Pro Max 512GB', N'Màn hình', N'OLED, 6.7", Super Retina XDR'
EXEC sp_AddCauHinh N'iPhone 12 Pro Max 512GB', N'Hệ điều hành', N'iOS 14'
EXEC sp_AddCauHinh N'iPhone 12 Pro Max 512GB', N'Camera sau', N'3 camera 12 MP'
EXEC sp_AddCauHinh N'iPhone 12 Pro Max 512GB', N'Camera trước', N'12 MP'
EXEC sp_AddCauHinh N'iPhone 12 Pro Max 512GB', N'Chip', N'Apple A14 Bionic'
EXEC sp_AddCauHinh N'iPhone 12 Pro Max 512GB', N'RAM', N'6 GB'
EXEC sp_AddCauHinh N'iPhone 12 Pro Max 512GB', N'Bộ nhớ trong', N'512 GB'
EXEC sp_AddCauHinh N'iPhone 12 Pro Max 512GB', N'SIM', N'1 Nano SIM & 1 eSIM, Hỗ trợ 5G'
EXEC sp_AddCauHinh N'iPhone 12 Pro Max 512GB', N'Pin, Sạc', N'3687 mAh, 20 W'

EXEC sp_AddCauHinh N'iPhone 13 mini 256GB', N'Màn hình', N'OLED, 5.4", Super Retina XDR'
EXEC sp_AddCauHinh N'iPhone 13 mini 256GB', N'Hệ điều hành', N'iOS 15'
EXEC sp_AddCauHinh N'iPhone 13 mini 256GB', N'Camera sau', N'2 camera 12 MP'
EXEC sp_AddCauHinh N'iPhone 13 mini 256GB', N'Camera trước', N'12 MP'
EXEC sp_AddCauHinh N'iPhone 13 mini 256GB', N'Chip', N'Apple A15 Bionic'
EXEC sp_AddCauHinh N'iPhone 13 mini 256GB', N'RAM', N'4 GB'
EXEC sp_AddCauHinh N'iPhone 13 mini 256GB', N'Bộ nhớ trong', N'256 GB'
EXEC sp_AddCauHinh N'iPhone 13 mini 256GB', N'SIM', N'1 Nano SIM & 1 eSIM, Hỗ trợ 5G'
EXEC sp_AddCauHinh N'iPhone 13 mini 256GB', N'Pin, Sạc', N'2438 mAh, 20 W'

EXEC sp_AddCauHinh N'iPhone 11 128GB', N'Màn hình', N'IPS LCD, 6.1", Liquid Retina'
EXEC sp_AddCauHinh N'iPhone 11 128GB', N'Hệ điều hành', N'iOS 14'
EXEC sp_AddCauHinh N'iPhone 11 128GB', N'Camera sau', N'2 camera 12 MP'
EXEC sp_AddCauHinh N'iPhone 11 128GB', N'Camera trước', N'12 MP'
EXEC sp_AddCauHinh N'iPhone 11 128GB', N'Chip', N'Apple A13 Bionic'
EXEC sp_AddCauHinh N'iPhone 11 128GB', N'RAM', N'4 GB'
EXEC sp_AddCauHinh N'iPhone 11 128GB', N'Bộ nhớ trong', N'128 GB'
EXEC sp_AddCauHinh N'iPhone 11 128GB', N'SIM', N'1 Nano SIM & 1 eSIM, Hỗ trợ 4G'
EXEC sp_AddCauHinh N'iPhone 11 128GB', N'Pin, Sạc', N'3110 mAh, 18 W'

EXEC sp_AddCauHinh N'iPhone XR 128GB', N'Màn hình', N'IPS LCD, 6.1", Liquid Retina'
EXEC sp_AddCauHinh N'iPhone XR 128GB', N'Hệ điều hành', N'iOS 14'
EXEC sp_AddCauHinh N'iPhone XR 128GB', N'Camera sau', N'12 MP'
EXEC sp_AddCauHinh N'iPhone XR 128GB', N'Camera trước', N'7 MP'
EXEC sp_AddCauHinh N'iPhone XR 128GB', N'Chip', N'Apple A12 Bionic'
EXEC sp_AddCauHinh N'iPhone XR 128GB', N'RAM', N'3 GB'
EXEC sp_AddCauHinh N'iPhone XR 128GB', N'Bộ nhớ trong', N'128 GB'
EXEC sp_AddCauHinh N'iPhone XR 128GB', N'SIM', N'1 Nano SIM & 1 eSIM, Hỗ trợ 4G'
EXEC sp_AddCauHinh N'iPhone XR 128GB', N'Pin, Sạc', N'2942 mAh, 15 W'

EXEC sp_AddCauHinh N'Samsung Galaxy Z Fold3 5G 512GB', N'Màn hình', N'Dynamic AMOLED 2X, Chính 7.6" & Phụ 6.2", Full HD+'
EXEC sp_AddCauHinh N'Samsung Galaxy Z Fold3 5G 512GB', N'Hệ điều hành', N'Android 11'
EXEC sp_AddCauHinh N'Samsung Galaxy Z Fold3 5G 512GB', N'Camera sau', N'3 camera 12 MP'
EXEC sp_AddCauHinh N'Samsung Galaxy Z Fold3 5G 512GB', N'Camera trước', N'10 MP & 4 MP'
EXEC sp_AddCauHinh N'Samsung Galaxy Z Fold3 5G 512GB', N'Chip', N'Snapdragon 888'
EXEC sp_AddCauHinh N'Samsung Galaxy Z Fold3 5G 512GB', N'RAM', N'12 GB'
EXEC sp_AddCauHinh N'Samsung Galaxy Z Fold3 5G 512GB', N'Bộ nhớ trong', N'512 GB'
EXEC sp_AddCauHinh N'Samsung Galaxy Z Fold3 5G 512GB', N'SIM', N'2 Nano SIM, Hỗ trợ 5G'
EXEC sp_AddCauHinh N'Samsung Galaxy Z Fold3 5G 512GB', N'Pin, Sạc', N'4400 mAh, 25 W'

EXEC sp_AddCauHinh N'Samsung Galaxy A03s', N'Màn hình', N'PLS LCD, 6.5", HD+'
EXEC sp_AddCauHinh N'Samsung Galaxy A03s', N'Hệ điều hành', N'Android 11'
EXEC sp_AddCauHinh N'Samsung Galaxy A03s', N'Camera sau', N'Chính 13 MP & Phụ 2 MP, 2 MP'
EXEC sp_AddCauHinh N'Samsung Galaxy A03s', N'Camera trước', N'5 MP'
EXEC sp_AddCauHinh N'Samsung Galaxy A03s', N'Chip', N'MediaTek MT6765'
EXEC sp_AddCauHinh N'Samsung Galaxy A03s', N'RAM', N'4 GB'
EXEC sp_AddCauHinh N'Samsung Galaxy A03s', N'Bộ nhớ trong', N'64 GB'
EXEC sp_AddCauHinh N'Samsung Galaxy A03s', N'SIM', N'2 Nano SIM, Hỗ trợ 4G'
EXEC sp_AddCauHinh N'Samsung Galaxy A03s', N'Pin, Sạc', N'5000 mAh, 7.75 W'

EXEC sp_AddCauHinh N'Samsung Galaxy M51', N'Màn hình', N'Super AMOLED Plus, 6.7", Full HD+'
EXEC sp_AddCauHinh N'Samsung Galaxy M51', N'Hệ điều hành', N'Android 10'
EXEC sp_AddCauHinh N'Samsung Galaxy M51', N'Camera sau', N'Chính 64 MP & Phụ 12 MP, 5 MP, 5 MP'
EXEC sp_AddCauHinh N'Samsung Galaxy M51', N'Camera trước', N'32 MP'
EXEC sp_AddCauHinh N'Samsung Galaxy M51', N'Chip', N'Snapdragon 730'
EXEC sp_AddCauHinh N'Samsung Galaxy M51', N'RAM', N'8 GB'
EXEC sp_AddCauHinh N'Samsung Galaxy M51', N'Bộ nhớ trong', N'128 GB'
EXEC sp_AddCauHinh N'Samsung Galaxy M51', N'SIM', N'2 Nano SIM, Hỗ trợ 4G'
EXEC sp_AddCauHinh N'Samsung Galaxy M51', N'Pin, Sạc', N'7000 mAh, 25 W'

EXEC sp_AddCauHinh N'Samsung Galaxy Z Flip3 5G 256GB', N'Màn hình', N'Dynamic AMOLED 2X, Chính 6.7" & Phụ 1.9", Full HD+'
EXEC sp_AddCauHinh N'Samsung Galaxy Z Flip3 5G 256GB', N'Hệ điều hành', N'Android 11'
EXEC sp_AddCauHinh N'Samsung Galaxy Z Flip3 5G 256GB', N'Camera sau', N'2 camera 12 MP'
EXEC sp_AddCauHinh N'Samsung Galaxy Z Flip3 5G 256GB', N'Camera trước', N'10 MP'
EXEC sp_AddCauHinh N'Samsung Galaxy Z Flip3 5G 256GB', N'Chip', N'Snapdragon 888'
EXEC sp_AddCauHinh N'Samsung Galaxy Z Flip3 5G 256GB', N'RAM', N'8 GB'
EXEC sp_AddCauHinh N'Samsung Galaxy Z Flip3 5G 256GB', N'Bộ nhớ trong', N'256 GB'
EXEC sp_AddCauHinh N'Samsung Galaxy Z Flip3 5G 256GB', N'SIM', N'1 Nano SIM & 1 eSIM, Hỗ trợ 5G'
EXEC sp_AddCauHinh N'Samsung Galaxy Z Flip3 5G 256GB', N'Pin, Sạc', N'3300 mAh, 15 W'

EXEC sp_AddCauHinh N'OPPO Reno6 Z 5G', N'Màn hình', N'AMOLED, 6.43", Full HD+'
EXEC sp_AddCauHinh N'OPPO Reno6 Z 5G', N'Hệ điều hành', N'Android 11'
EXEC sp_AddCauHinh N'OPPO Reno6 Z 5G', N'Camera sau', N'Chính 64 MP & Phụ 8 MP, 2 MP'
EXEC sp_AddCauHinh N'OPPO Reno6 Z 5G', N'Camera trước', N'32 MP'
EXEC sp_AddCauHinh N'OPPO Reno6 Z 5G', N'Chip', N'MediaTek Dimensity 800U 5G'
EXEC sp_AddCauHinh N'OPPO Reno6 Z 5G', N'RAM', N'8 GB'
EXEC sp_AddCauHinh N'OPPO Reno6 Z 5G', N'Bộ nhớ trong', N'128 GB'
EXEC sp_AddCauHinh N'OPPO Reno6 Z 5G', N'SIM', N'2 Nano SIM, Hỗ trợ 5G'
EXEC sp_AddCauHinh N'OPPO Reno6 Z 5G', N'Pin, Sạc', N'4310 mAh, 30 W'

EXEC sp_AddCauHinh N'OPPO A74', N'Màn hình', N'AMOLED, 6.43", Full HD+'
EXEC sp_AddCauHinh N'OPPO A74', N'Hệ điều hành', N'Android 11'
EXEC sp_AddCauHinh N'OPPO A74', N'Camera sau', N'Chính 48 MP & Phụ 2 MP, 2 MP'
EXEC sp_AddCauHinh N'OPPO A74', N'Camera trước', N'16 MP'
EXEC sp_AddCauHinh N'OPPO A74', N'Chip', N'Snapdragon 662'
EXEC sp_AddCauHinh N'OPPO A74', N'RAM', N'8 GB'
EXEC sp_AddCauHinh N'OPPO A74', N'Bộ nhớ trong', N'128 GB'
EXEC sp_AddCauHinh N'OPPO A74', N'SIM', N'2 Nano SIM, Hỗ trợ 4G'
EXEC sp_AddCauHinh N'OPPO A74', N'Pin, Sạc', N'5000 mAh, 33 W'

EXEC sp_AddCauHinh N'OPPO A55', N'Màn hình', N'IPS LCD, 6.5", HD+'
EXEC sp_AddCauHinh N'OPPO A55', N'Hệ điều hành', N'Android 11'
EXEC sp_AddCauHinh N'OPPO A55', N'Camera sau', N'Chính 50 MP & Phụ 2 MP, 2 MP'
EXEC sp_AddCauHinh N'OPPO A55', N'Camera trước', N'16 MP'
EXEC sp_AddCauHinh N'OPPO A55', N'Chip', N'MediaTek Helio G35'
EXEC sp_AddCauHinh N'OPPO A55', N'RAM', N'4 GB'
EXEC sp_AddCauHinh N'OPPO A55', N'Bộ nhớ trong', N'64 GB'
EXEC sp_AddCauHinh N'OPPO A55', N'SIM', N'2 Nano SIM, Hỗ trợ 4G'
EXEC sp_AddCauHinh N'OPPO A55', N'Pin, Sạc', N'5000 mAh, 18 W'

EXEC sp_AddCauHinh N'OPPO Reno5 Marvel', N'Màn hình', N'AMOLED, 6.43", HD+'
EXEC sp_AddCauHinh N'OPPO Reno5 Marvel', N'Hệ điều hành', N'Android 11'
EXEC sp_AddCauHinh N'OPPO Reno5 Marvel', N'Camera sau', N'Chính 64 MP & Phụ 8 MP, 2 MP, 2 MP'
EXEC sp_AddCauHinh N'OPPO Reno5 Marvel', N'Camera trước', N'44 MP'
EXEC sp_AddCauHinh N'OPPO Reno5 Marvel', N'Chip', N'Snapdragon 720G'
EXEC sp_AddCauHinh N'OPPO Reno5 Marvel', N'RAM', N'8 GB'
EXEC sp_AddCauHinh N'OPPO Reno5 Marvel', N'Bộ nhớ trong', N'128 GB'
EXEC sp_AddCauHinh N'OPPO Reno5 Marvel', N'SIM', N'2 Nano SIM, Hỗ trợ 4G'
EXEC sp_AddCauHinh N'OPPO Reno5 Marvel', N'Pin, Sạc', N'4310 mAh, 50 W'

EXEC sp_AddCauHinh N'Vivo Y21', N'Màn hình', N'IPS LCD, 6.51", HD+'
EXEC sp_AddCauHinh N'Vivo Y21', N'Hệ điều hành', N'Android 11'
EXEC sp_AddCauHinh N'Vivo Y21', N'Camera sau', N'Chính 13 MP & Phụ 2 MP'
EXEC sp_AddCauHinh N'Vivo Y21', N'Camera trước', N'8 MP'
EXEC sp_AddCauHinh N'Vivo Y21', N'Chip', N'MediaTek Helio P35'
EXEC sp_AddCauHinh N'Vivo Y21', N'RAM', N'4 GB'
EXEC sp_AddCauHinh N'Vivo Y21', N'Bộ nhớ trong', N'64 GB'
EXEC sp_AddCauHinh N'Vivo Y21', N'SIM', N'2 Nano SIM, Hỗ trợ 4G'
EXEC sp_AddCauHinh N'Vivo Y21', N'Pin, Sạc', N'5000 mAh, 18 W'

EXEC sp_AddCauHinh N'Vivo X70 Pro 5G', N'Màn hình', N'AMOLED, 6.56", Full HD+'
EXEC sp_AddCauHinh N'Vivo X70 Pro 5G', N'Hệ điều hành', N'Android 11'
EXEC sp_AddCauHinh N'Vivo X70 Pro 5G', N'Camera sau', N'Chính 50 MP & Phụ 12 MP, 12 MP, 8 MP'
EXEC sp_AddCauHinh N'Vivo X70 Pro 5G', N'Camera trước', N'32 MP'
EXEC sp_AddCauHinh N'Vivo X70 Pro 5G', N'Chip', N'MediaTek Dimensity 1200'
EXEC sp_AddCauHinh N'Vivo X70 Pro 5G', N'RAM', N'12 GB'
EXEC sp_AddCauHinh N'Vivo X70 Pro 5G', N'Bộ nhớ trong', N'256 GB'
EXEC sp_AddCauHinh N'Vivo X70 Pro 5G', N'SIM', N'2 Nano SIM, Hỗ trợ 5G'
EXEC sp_AddCauHinh N'Vivo X70 Pro 5G', N'Pin, Sạc', N'4450 mAh, 44 W'

EXEC sp_AddCauHinh N'Vivo Y72 5G', N'Màn hình', N'IPS LCD, 6.58", Full HD+'
EXEC sp_AddCauHinh N'Vivo Y72 5G', N'Hệ điều hành', N'Android 11'
EXEC sp_AddCauHinh N'Vivo Y72 5G', N'Camera sau', N'Chính 64 MP & Phụ 8 MP, 2 MP'
EXEC sp_AddCauHinh N'Vivo Y72 5G', N'Camera trước', N'16 MP'
EXEC sp_AddCauHinh N'Vivo Y72 5G', N'Chip', N'MediaTek Dimensity 700'
EXEC sp_AddCauHinh N'Vivo Y72 5G', N'RAM', N'8 GB'
EXEC sp_AddCauHinh N'Vivo Y72 5G', N'Bộ nhớ trong', N'128 GB'
EXEC sp_AddCauHinh N'Vivo Y72 5G', N'SIM', N'2 Nano SIM (SIM 2 chung khe thẻ nhớ), Hỗ trợ 5G'
EXEC sp_AddCauHinh N'Vivo Y72 5G', N'Pin, Sạc', N'5000 mAh, 18 W'

EXEC sp_AddCauHinh N'Vivo V20 SE', N'Màn hình', N'AMOLED, 6.44", Full HD+'
EXEC sp_AddCauHinh N'Vivo V20 SE', N'Hệ điều hành', N'Android 10'
EXEC sp_AddCauHinh N'Vivo V20 SE', N'Camera sau', N'Chính 48 MP & Phụ 8 MP, 2 MP'
EXEC sp_AddCauHinh N'Vivo V20 SE', N'Camera trước', N'32 MP'
EXEC sp_AddCauHinh N'Vivo V20 SE', N'Chip', N'Snapdragon 665'
EXEC sp_AddCauHinh N'Vivo V20 SE', N'RAM', N'8 GB'
EXEC sp_AddCauHinh N'Vivo V20 SE', N'Bộ nhớ trong', N'128 GB'
EXEC sp_AddCauHinh N'Vivo V20 SE', N'SIM', N'2 Nano SIM, Hỗ trợ 4G'
EXEC sp_AddCauHinh N'Vivo V20 SE', N'Pin, Sạc', N'4100 mAh, 33 W'

EXEC sp_AddCauHinh N'Xiaomi 11T 5G 256GB', N'Màn hình', N'AMOLED, 6.67", Full HD+'
EXEC sp_AddCauHinh N'Xiaomi 11T 5G 256GB', N'Hệ điều hành', N'Android 11'
EXEC sp_AddCauHinh N'Xiaomi 11T 5G 256GB', N'Camera sau', N'Chính 108 MP & Phụ 8 MP, 5 MP'
EXEC sp_AddCauHinh N'Xiaomi 11T 5G 256GB', N'Camera trước', N'16 MP'
EXEC sp_AddCauHinh N'Xiaomi 11T 5G 256GB', N'Chip', N'MediaTek Dimensity 1200'
EXEC sp_AddCauHinh N'Xiaomi 11T 5G 256GB', N'RAM', N'8 GB'
EXEC sp_AddCauHinh N'Xiaomi 11T 5G 256GB', N'Bộ nhớ trong', N'256 GB'
EXEC sp_AddCauHinh N'Xiaomi 11T 5G 256GB', N'SIM', N'2 Nano SIM, Hỗ trợ 5G'
EXEC sp_AddCauHinh N'Xiaomi 11T 5G 256GB', N'Pin, Sạc', N'5000 mAh, 67 W'

EXEC sp_AddCauHinh N'Xiaomi 11 Lite 5G NE', N'Màn hình', N'AMOLED, 6.55", Full HD+'
EXEC sp_AddCauHinh N'Xiaomi 11 Lite 5G NE', N'Hệ điều hành', N'Android 11'
EXEC sp_AddCauHinh N'Xiaomi 11 Lite 5G NE', N'Camera sau', N'Chính 64 MP & Phụ 8 MP, 5 MP'
EXEC sp_AddCauHinh N'Xiaomi 11 Lite 5G NE', N'Camera trước', N'20 MP'
EXEC sp_AddCauHinh N'Xiaomi 11 Lite 5G NE', N'Chip', N'Snapdragon 778G 5G 8 nhân'
EXEC sp_AddCauHinh N'Xiaomi 11 Lite 5G NE', N'RAM', N'8 GB'
EXEC sp_AddCauHinh N'Xiaomi 11 Lite 5G NE', N'Bộ nhớ trong', N'128 GB'
EXEC sp_AddCauHinh N'Xiaomi 11 Lite 5G NE', N'SIM', N'2 Nano SIM (SIM 2 chung khe thẻ nhớ), Hỗ trợ 5G'
EXEC sp_AddCauHinh N'Xiaomi 11 Lite 5G NE', N'Pin, Sạc', N'4250 mAh, 33 W'

EXEC sp_AddCauHinh N'Xiaomi Redmi Note 9', N'Màn hình', N'IPS LCD, 6.53", Full HD+'
EXEC sp_AddCauHinh N'Xiaomi Redmi Note 9', N'Hệ điều hành', N'Android 10'
EXEC sp_AddCauHinh N'Xiaomi Redmi Note 9', N'Camera sau', N'Chính 48 MP & Phụ 8 MP, 2 MP, 2 MP'
EXEC sp_AddCauHinh N'Xiaomi Redmi Note 9', N'Camera trước', N'13 MP'
EXEC sp_AddCauHinh N'Xiaomi Redmi Note 9', N'Chip', N'MediaTek Helio G85'
EXEC sp_AddCauHinh N'Xiaomi Redmi Note 9', N'RAM', N'4 GB'
EXEC sp_AddCauHinh N'Xiaomi Redmi Note 9', N'Bộ nhớ trong', N'128 GB'
EXEC sp_AddCauHinh N'Xiaomi Redmi Note 9', N'SIM', N'2 Nano SIM, Hỗ trợ 4G'
EXEC sp_AddCauHinh N'Xiaomi Redmi Note 9', N'Pin, Sạc', N'5020 mAh, 18 W'

EXEC sp_AddCauHinh N'Xiaomi Redmi Note 10S', N'Màn hình', N'AMOLED, 6.43", Full HD+'
EXEC sp_AddCauHinh N'Xiaomi Redmi Note 10S', N'Hệ điều hành', N'Android 11'
EXEC sp_AddCauHinh N'Xiaomi Redmi Note 10S', N'Camera sau', N'Chính 64 MP & Phụ 8 MP, 2 MP, 2 MP'
EXEC sp_AddCauHinh N'Xiaomi Redmi Note 10S', N'Camera trước', N'13 MP'
EXEC sp_AddCauHinh N'Xiaomi Redmi Note 10S', N'Chip', N'MediaTek Helio G95'
EXEC sp_AddCauHinh N'Xiaomi Redmi Note 10S', N'RAM', N'8 GB'
EXEC sp_AddCauHinh N'Xiaomi Redmi Note 10S', N'Bộ nhớ trong', N'128 GB'
EXEC sp_AddCauHinh N'Xiaomi Redmi Note 10S', N'SIM', N'2 Nano SIM, Hỗ trợ 4G'
EXEC sp_AddCauHinh N'Xiaomi Redmi Note 10S', N'Pin, Sạc', N'5000 mAh, 33 W'

--SẠC DỰ PHÒNG
EXEC sp_AddCauHinh N'Pin sạc dự phòng Polymer 10.000 mAh Type C Xiaomi Power Bank 3 Ultra Compact', N'Hiệu suất sạc', N'55%'
EXEC sp_AddCauHinh N'Pin sạc dự phòng Polymer 10.000 mAh Type C Xiaomi Power Bank 3 Ultra Compact', N'Dung lượng pin', N'10.000 mAh'
EXEC sp_AddCauHinh N'Pin sạc dự phòng Polymer 10.000 mAh Type C Xiaomi Power Bank 3 Ultra Compact', N'Thời gian sạc đầy pin', N'10 - 11 giờ (dùng Adapter 1A)6 - 8 giờ (dùng Adapter 2A)'
EXEC sp_AddCauHinh N'Pin sạc dự phòng Polymer 10.000 mAh Type C Xiaomi Power Bank 3 Ultra Compact', N'Nguồn vào', N'Type C: 5V - 3A, 9V - 2.5A, 12V - 1.85AMicro USB: 5V - 2A, 9V - 2A'
EXEC sp_AddCauHinh N'Pin sạc dự phòng Polymer 10.000 mAh Type C Xiaomi Power Bank 3 Ultra Compact', N'Nguồn ra', N'Type C: 5V - 3A, 9V - 2.5A, 12V - 1.85AUSB: 5V - 2.4A, 9V - 2.5A, 12V - 1.85A'
EXEC sp_AddCauHinh N'Pin sạc dự phòng Polymer 10.000 mAh Type C Xiaomi Power Bank 3 Ultra Compact', N'Lõi pin', N'Polymer'
EXEC sp_AddCauHinh N'Pin sạc dự phòng Polymer 10.000 mAh Type C Xiaomi Power Bank 3 Ultra Compact', N'Công nghệ/Tiện ích', N'Đèn LED báo hiệu Power Delivery'
EXEC sp_AddCauHinh N'Pin sạc dự phòng Polymer 10.000 mAh Type C Xiaomi Power Bank 3 Ultra Compact', N'Kích thước', N'Dài 9 cm - Rộng 6.5 cm - Dày 2.5 cm'
EXEC sp_AddCauHinh N'Pin sạc dự phòng Polymer 10.000 mAh Type C Xiaomi Power Bank 3 Ultra Compact', N'Trọng lượng', N'200 g'

EXEC sp_AddCauHinh N'Pin sạc dự phòng Polymer 10.000mAh Type C Fast Charge Xiaomi Mi Power Bank 3', N'Hiệu suất sạc', N'55%'
EXEC sp_AddCauHinh N'Pin sạc dự phòng Polymer 10.000mAh Type C Fast Charge Xiaomi Mi Power Bank 3 ', N'Dung lượng pin', N'10.000 mAh'
EXEC sp_AddCauHinh N'Pin sạc dự phòng Polymer 10.000mAh Type C Fast Charge Xiaomi Mi Power Bank 3 ', N'Thời gian sạc đầy pin', N'10 - 11 giờ (dùng Adapter 1A)3 - 4 giờ (dùng 9V/2A hoặc 12V/1.5A)5 - 6 giờ (dùng Adapter 2A)'
EXEC sp_AddCauHinh N'Pin sạc dự phòng Polymer 10.000mAh Type C Fast Charge Xiaomi Mi Power Bank 3 ', N'Nguồn vào', N'Micro USB/ Type C: 5V - 2.6A, 9V - 2.1A, 12V - 1.5A (18W MAX)'
EXEC sp_AddCauHinh N'Pin sạc dự phòng Polymer 10.000mAh Type C Fast Charge Xiaomi Mi Power Bank 3 ', N'Nguồn ra', N'USB: 5V - 2.6A, 9V - 2.1A, 12V - 1.5AUSB: 5V - 2.6A'
EXEC sp_AddCauHinh N'Pin sạc dự phòng Polymer 10.000mAh Type C Fast Charge Xiaomi Mi Power Bank 3 ', N'Lõi pin', N'Polymer'
EXEC sp_AddCauHinh N'Pin sạc dự phòng Polymer 10.000mAh Type C Fast Charge Xiaomi Mi Power Bank 3 ', N'Công nghệ/Tiện ích', N'Quick Charge 3.0. Đèn LED báo hiệu'
EXEC sp_AddCauHinh N'Pin sạc dự phòng Polymer 10.000mAh Type C Fast Charge Xiaomi Mi Power Bank 3 ', N'Kích thước', N'Dài 14.8cm - Rộng 7.4cm - Dày 1.5cm'
EXEC sp_AddCauHinh N'Pin sạc dự phòng Polymer 10.000mAh Type C Fast Charge Xiaomi Mi Power Bank 3 ', N'Trọng lượng', N'343g'

EXEC sp_AddCauHinh N'Pin sạc dự phòng Polymer 10.000 mAh Type C PD Samsung EB-P3300', N'Hiệu suất sạc', N'55%'
EXEC sp_AddCauHinh N'Pin sạc dự phòng Polymer 10.000 mAh Type C PD Samsung EB-P3300', N'Dung lượng pin', N'10.000 mAh'
EXEC sp_AddCauHinh N'Pin sạc dự phòng Polymer 10.000 mAh Type C PD Samsung EB-P3300', N'Thời gian sạc đầy pin', N'10 - 11 giờ (dùng Adapter 1A)6 - 8 giờ (dùng Adapter 2A)'
EXEC sp_AddCauHinh N'Pin sạc dự phòng Polymer 10.000 mAh Type C PD Samsung EB-P3300', N'Nguồn vào', N'Type C: 5V - 2A, 9V - 1.67A, 12V - 2.1A (Adaptive Fast Charging)Type C: 5V - 3A, 9V - 2.77A (Power Delivery)'
EXEC sp_AddCauHinh N'Pin sạc dự phòng Polymer 10.000 mAh Type C PD Samsung EB-P3300', N'Nguồn ra', N'USB: 5V - 2A, 9V - 1.7A, 12V - 2.1AType C: 5V - 2A, 9V - 2A, 12V - 2.1A'
EXEC sp_AddCauHinh N'Pin sạc dự phòng Polymer 10.000 mAh Type C PD Samsung EB-P3300', N'Lõi pin', N'Polymer'
EXEC sp_AddCauHinh N'Pin sạc dự phòng Polymer 10.000 mAh Type C PD Samsung EB-P3300', N'Công nghệ/Tiện ích', N'Super Fast Charging. Đèn LED báo hiệu Power Delivery'
EXEC sp_AddCauHinh N'Pin sạc dự phòng Polymer 10.000 mAh Type C PD Samsung EB-P3300', N'Kích thước', N'Dài 14 cm - Ngang 7 cm - Dày 1.3 cm'
EXEC sp_AddCauHinh N'Pin sạc dự phòng Polymer 10.000 mAh Type C PD Samsung EB-P3300', N'Trọng lượng', N'240 g'

EXEC sp_AddCauHinh N'Pin sạc dự phòng Polymer 20.000 mAh Type C PD Energizer UE20011PQ', N'Hiệu suất sạc', N'64%'
EXEC sp_AddCauHinh N'Pin sạc dự phòng Polymer 20.000 mAh Type C PD Energizer UE20011PQ', N'Dung lượng pin', N'20.000 mAh'
EXEC sp_AddCauHinh N'Pin sạc dự phòng Polymer 20.000 mAh Type C PD Energizer UE20011PQ', N'Thời gian sạc đầy pin', N'12 - 14 giờ (dùng Adapter 2A)'
EXEC sp_AddCauHinh N'Pin sạc dự phòng Polymer 20.000 mAh Type C PD Energizer UE20011PQ', N'Nguồn vào', N'Micro USB: 5V - 2AType-C: 5V - 2A, 9V - 2A'
EXEC sp_AddCauHinh N'Pin sạc dự phòng Polymer 20.000 mAh Type C PD Energizer UE20011PQ', N'Nguồn ra', N'Type C: 5V - 2A, 9V - 2A, 12V - 1.5AUSB: 5V - 4.5A, 9V - 2A, 12V - 1.5A'
EXEC sp_AddCauHinh N'Pin sạc dự phòng Polymer 20.000 mAh Type C PD Energizer UE20011PQ', N'Lõi pin', N'Polymer'
EXEC sp_AddCauHinh N'Pin sạc dự phòng Polymer 20.000 mAh Type C PD Energizer UE20011PQ', N'Công nghệ/Tiện ích', N'Auto Voltage Sensing Power Delivery'
EXEC sp_AddCauHinh N'Pin sạc dự phòng Polymer 20.000 mAh Type C PD Energizer UE20011PQ', N'Kích thước', N'Dài 14 cm - Rộng 6.9 cm - Dày 2.8 cm'
EXEC sp_AddCauHinh N'Pin sạc dự phòng Polymer 20.000 mAh Type C PD Energizer UE20011PQ', N'Trọng lượng', N'415 g'

-- BẢNG HÓA ĐƠN VÀ CHITIETHD
DECLARE @maHD_ VARCHAR(10)

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Lê Thị Linh', N'Đỗ Gia Nguyên', N'OPPO A74', 1
EXEC sp_AddHD @maHD_, N'Lê Thị Linh', N'Đỗ Gia Nguyên', N'Pin sạc dự phòng Polymer 20.000 mAh Type C PD Energizer UE20011PQ', 2
EXEC sp_AddHD @maHD_, N'Lê Thị Linh', N'Đỗ Gia Nguyên', N'iPhone 13 Pro Max 1TB', 1
UPDATE HOADON set NGTAO = '1/10/2019' WHERE ID = @maHD_

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Cao Gia Vinh', N'Từ Huệ Sơn', N'iPhone XR 128GB', 1
EXEC sp_AddHD @maHD_, N'Cao Gia Vinh', N'Từ Huệ Sơn', N'Pin sạc dự phòng Polymer 20.000 mAh Type C PD Energizer UE20011PQ', 1
EXEC sp_AddHD @maHD_, N'Cao Gia Vinh', N'Từ Huệ Sơn', N'Samsung Galaxy M51', 1
UPDATE HOADON set NGTAO = '2/13/2019' WHERE ID = @maHD_

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Cao Gia Vinh', N'Đỗ Gia Nguyên', N'iPhone XR 128GB', 1
EXEC sp_AddHD @maHD_, N'Cao Gia Vinh', N'Đỗ Gia Nguyên', N'Adapter Sạc Type C PD 25W Samsung EP-TA800N', 1
EXEC sp_AddHD @maHD_, N'Cao Gia Vinh', N'Đỗ Gia Nguyên', N'Vivo Y21', 2
UPDATE HOADON set NGTAO = '3/2/2019' WHERE ID = @maHD_

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Nguyễn Thị Thương', N'Từ Huệ Sơn', N'iPhone 13 Pro Max 1TB', 1
EXEC sp_AddHD @maHD_, N'Nguyễn Thị Thương', N'Từ Huệ Sơn', N'Gậy chụp ảnh Bluetooth Tripod Xmobile K06 Đen', 2
EXEC sp_AddHD @maHD_, N'Nguyễn Thị Thương', N'Từ Huệ Sơn', N'Vivo Y21', 1
EXEC sp_AddHD @maHD_, N'Nguyễn Thị Thương', N'Từ Huệ Sơn', N'iPhone 12 Pro Max 512GB', 1
UPDATE HOADON set NGTAO = '4/21/2019' WHERE ID = @maHD_

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Hồ Minh Ngọc', N'Lê Đức Tài', N'iPhone 13 Pro Max 512GB', 1
EXEC sp_AddHD @maHD_, N'Hồ Minh Ngọc', N'Lê Đức Tài', N'Pin sạc dự phòng Polymer 10.000 mAh Type C Xiaomi Power Bank 3 Ultra Compact', 2
EXEC sp_AddHD @maHD_, N'Hồ Minh Ngọc', N'Lê Đức Tài', N'Túi chống nước Cosano 5 inch Vàng Chanh', 1
EXEC sp_AddHD @maHD_, N'Hồ Minh Ngọc', N'Lê Đức Tài', N'Cáp Type-C 1.2 m Energizer C41C2AGBKT Đen', 1
UPDATE HOADON set NGTAO = '5/22/2019' WHERE ID = @maHD_

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Lý Gia Huy', N'Nguyễn văn Tèo', N'iPhone 13 Pro Max 512GB', 1
EXEC sp_AddHD @maHD_, N'Lý Gia Huy', N'Nguyễn văn Tèo', N'Realme 8 Pro Vàng Rực Rỡ', 1
EXEC sp_AddHD @maHD_, N'Lý Gia Huy', N'Nguyễn văn Tèo', N'Cáp Type-C 1.2 m Energizer C41C2AGBKT Đen', 1
UPDATE HOADON set NGTAO = '6/20/2019' WHERE ID = @maHD_

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Nguyễn Văn Cao', N'Nguyễn văn Tèo', N'iPhone 13 Pro Max 512GB', 1
EXEC sp_AddHD @maHD_, N'Nguyễn Văn Cao', N'Nguyễn văn Tèo', N'Cáp Type-C 1.2 m Energizer C41C2AGBKT Đen', 1
EXEC sp_AddHD @maHD_, N'Nguyễn Văn Cao', N'Nguyễn văn Tèo', N'Realme 6 Pro', 1
EXEC sp_AddHD @maHD_, N'Nguyễn Văn Cao', N'Nguyễn văn Tèo', N'Pin sạc dự phòng Polymer 10.000 mAh Type C PD Samsung EB-P3300', 1
UPDATE HOADON set NGTAO = '7/16/2019' WHERE ID = @maHD_

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Huỳnh Ái Linh', N'Lê Đức Tài', N'Pin sạc dự phòng Polymer 20.000 mAh Type C PD Energizer UE20011PQ', 1
EXEC sp_AddHD @maHD_, N'Huỳnh Ái Linh', N'Lê Đức Tài', N'Samsung Galaxy A03s', 1
EXEC sp_AddHD @maHD_, N'Huỳnh Ái Linh', N'Lê Đức Tài', N'iPhone 13 Pro 1TB', 1
UPDATE HOADON set NGTAO = '8/2/2019' WHERE ID = @maHD_

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Nguyễn Thị Thương', N'Từ Huệ Sơn', N'iPhone 13 Pro 1TB', 1
EXEC sp_AddHD @maHD_, N'Nguyễn Thị Thương', N'Từ Huệ Sơn', N'Realme 6 Pro', 1
EXEC sp_AddHD @maHD_, N'Nguyễn Thị Thương', N'Từ Huệ Sơn', N'Pin sạc dự phòng Polymer 10.000 mAh Type C Xiaomi Power Bank 3 Ultra Compact', 2
UPDATE HOADON set NGTAO = '9/11/2019' WHERE ID = @maHD_

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Trần Ngọc Sang', N'Lê Đức Tài', N'Adapter Sạc Type C PD 25W Samsung EP-TA800N', 1
EXEC sp_AddHD @maHD_, N'Trần Ngọc Sang', N'Lê Đức Tài', N'Samsung Galaxy Z Fold3 5G 512GB', 1
EXEC sp_AddHD @maHD_, N'Trần Ngọc Sang', N'Lê Đức Tài', N'OPPO Reno6 Z 5G', 1
UPDATE HOADON set NGTAO = '10/4/2019' WHERE ID = @maHD_

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Huỳnh Ái Linh', N'Lê Đức Tài', N'Samsung Galaxy Z Flip3 5G 256GB', 1
EXEC sp_AddHD @maHD_, N'Huỳnh Ái Linh', N'Lê Đức Tài', N'Ốp lưng iPhone 13 Silicon OSMIA Cam', 1
EXEC sp_AddHD @maHD_, N'Huỳnh Ái Linh', N'Lê Đức Tài', N'Dây đeo điện thoại OSMIA silicon CRS', 1
EXEC sp_AddHD @maHD_, N'Huỳnh Ái Linh', N'Lê Đức Tài', N'Pin sạc dự phòng Polymer 10.000mAh Type C Fast Charge Xiaomi Mi Power Bank 3', 1
UPDATE HOADON set NGTAO = '11/2/2019' WHERE ID = @maHD_

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Đỗ Ái Vy', N'Từ Huệ Sơn', N'Samsung Galaxy M51', 2
EXEC sp_AddHD @maHD_, N'Đỗ Ái Vy', N'Từ Huệ Sơn', N'Xiaomi Redmi Note 10S', 1
EXEC sp_AddHD @maHD_, N'Đỗ Ái Vy', N'Từ Huệ Sơn', N'Nokia 6300 4G', 1
EXEC sp_AddHD @maHD_, N'Đỗ Ái Vy', N'Từ Huệ Sơn', N'Adapter Sạc Type C PD 25W Samsung EP-TA800N', 2
UPDATE HOADON set NGTAO = '12/12/2019' WHERE ID = @maHD_

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Nguyễn Văn Cao', N'Từ Huệ Sơn', N'Pin sạc dự phòng Polymer 20.000 mAh Type C PD Energizer UE20011PQ', 2
EXEC sp_AddHD @maHD_, N'Nguyễn Văn Cao', N'Từ Huệ Sơn', N'Bộ 2 móc điện thoại OSMIA CK-CRS10 Mèo cá heo xanh', 1
EXEC sp_AddHD @maHD_, N'Nguyễn Văn Cao', N'Từ Huệ Sơn', N'Xiaomi Redmi Note 9', 2
EXEC sp_AddHD @maHD_, N'Nguyễn Văn Cao', N'Từ Huệ Sơn', N'iPhone 11 128GB', 1
EXEC sp_AddHD @maHD_, N'Nguyễn Văn Cao', N'Từ Huệ Sơn', N'Gậy chụp ảnh Bluetooth Tripod Xmobile K06 Đen', 3
UPDATE HOADON set NGTAO = '1/2/2020' WHERE ID = @maHD_

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Lê Hồng Đào', N'Trần Vũ', N'Cáp Type-C 1.2 m Energizer C41C2AGBKT Đen', 2
EXEC sp_AddHD @maHD_, N'Lê Hồng Đào', N'Trần Vũ', N'Túi chống nước Cosano 5 inch Vàng Chanh', 3
EXEC sp_AddHD @maHD_, N'Lê Hồng Đào', N'Trần Vũ', N'OPPO A74', 1
EXEC sp_AddHD @maHD_, N'Lê Hồng Đào', N'Trần Vũ', N'iPhone 13 Pro Max 1TB', 1
EXEC sp_AddHD @maHD_, N'Lê Hồng Đào', N'Trần Vũ', N'Pin sạc dự phòng Polymer 10.000 mAh Type C PD Samsung EB-P3300', 2
UPDATE HOADON set NGTAO = '2/21/2020' WHERE ID = @maHD_

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Hồ Minh Ngọc', N'Từ Huệ Sơn', N'Cáp Type-C 1.2 m Energizer C41C2AGBKT Đen', 2
EXEC sp_AddHD @maHD_, N'Hồ Minh Ngọc', N'Từ Huệ Sơn', N'Túi chống nước Cosano 5 inch Vàng Chanh', 3
EXEC sp_AddHD @maHD_, N'Hồ Minh Ngọc', N'Từ Huệ Sơn', N'iPhone 13 Pro Max 1TB', 1
EXEC sp_AddHD @maHD_, N'Hồ Minh Ngọc', N'Từ Huệ Sơn', N'Ốp lưng iPhone 13 Silicon OSMIA Cam', 1
EXEC sp_AddHD @maHD_, N'Hồ Minh Ngọc', N'Từ Huệ Sơn', N'Xiaomi Redmi Note 10S', 1
UPDATE HOADON set NGTAO = '3/11/2020' WHERE ID = @maHD_

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Đỗ Ái Vy', N'Nguyễn văn Tèo', N'Cáp Type-C 1.2 m Energizer C41C2AGBKT Đen', 2
EXEC sp_AddHD @maHD_, N'Đỗ Ái Vy', N'Nguyễn văn Tèo', N'OPPO A74', 1
EXEC sp_AddHD @maHD_, N'Đỗ Ái Vy', N'Nguyễn văn Tèo', N'Vivo X70 Pro 5G', 1
EXEC sp_AddHD @maHD_, N'Đỗ Ái Vy', N'Nguyễn văn Tèo', N'Dây đeo điện thoại OSMIA silicon CRS', 1
EXEC sp_AddHD @maHD_, N'Đỗ Ái Vy', N'Nguyễn văn Tèo', N'Túi chống nước Cosano 5 inch Vàng Chanh', 1
UPDATE HOADON set NGTAO = '4/3/2020' WHERE ID = @maHD_

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Lý Gia Huy', N'Đỗ Gia Nguyên', N'Adapter Sạc Type C PD 25W Samsung EP-TA800N', 2
EXEC sp_AddHD @maHD_, N'Lý Gia Huy', N'Đỗ Gia Nguyên', N'Samsung Galaxy Z Fold3 5G 512GB', 1
EXEC sp_AddHD @maHD_, N'Lý Gia Huy', N'Đỗ Gia Nguyên', N'Samsung Galaxy M51', 1
EXEC sp_AddHD @maHD_, N'Lý Gia Huy', N'Đỗ Gia Nguyên', N'Pin sạc dự phòng Polymer 10.000 mAh Type C Xiaomi Power Bank 3 Ultra Compact', 1
UPDATE HOADON set NGTAO = '5/17/2020' WHERE ID = @maHD_

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Huỳnh Ái Linh', N'Đào kim huệ', N'Adapter Sạc Type C PD 25W Samsung EP-TA800N', 2
EXEC sp_AddHD @maHD_, N'Huỳnh Ái Linh', N'Đào kim huệ', N'OPPO A74', 1
EXEC sp_AddHD @maHD_, N'Huỳnh Ái Linh', N'Đào kim huệ', N'iPhone 11 128GB', 1
EXEC sp_AddHD @maHD_, N'Huỳnh Ái Linh', N'Đào kim huệ', N'Pin sạc dự phòng Polymer 10.000 mAh Type C Xiaomi Power Bank 3 Ultra Compact', 1
EXEC sp_AddHD @maHD_, N'Huỳnh Ái Linh', N'Đào kim huệ', N'Gậy Chụp Ảnh Bluetooth Cosano HD-P7', 1
UPDATE HOADON set NGTAO = '5/27/2020' WHERE ID = @maHD_

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Đỗ Ái Vy', N'Lê Đức Tài', N'Adapter Sạc Type C PD 25W Samsung EP-TA800N', 2
EXEC sp_AddHD @maHD_, N'Đỗ Ái Vy', N'Lê Đức Tài', N'iPhone 13 Pro Max 1TB', 1
EXEC sp_AddHD @maHD_, N'Đỗ Ái Vy', N'Lê Đức Tài', N'Miếng dán kính iPhone 13 Pro Max JCPAL', 1
EXEC sp_AddHD @maHD_, N'Đỗ Ái Vy', N'Lê Đức Tài', N'Ốp lưng iPhone 13 Silicon OSMIA Cam', 1
EXEC sp_AddHD @maHD_, N'Đỗ Ái Vy', N'Lê Đức Tài', N'iPhone 11 128GB', 1
EXEC sp_AddHD @maHD_, N'Đỗ Ái Vy', N'Lê Đức Tài', N'Pin sạc dự phòng Polymer 10.000 mAh Type C Xiaomi Power Bank 3 Ultra Compact', 1
UPDATE HOADON set NGTAO = '6/7/2020' WHERE ID = @maHD_

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Hồ Minh Ngọc', N'vũ thanh long', N'OPPO A74', 1
EXEC sp_AddHD @maHD_, N'Hồ Minh Ngọc', N'vũ thanh long', N'OPPO Reno5 Marvel', 1
EXEC sp_AddHD @maHD_, N'Hồ Minh Ngọc', N'vũ thanh long', N'iPhone 13 Pro Max 1TB', 1
EXEC sp_AddHD @maHD_, N'Hồ Minh Ngọc', N'vũ thanh long', N'Miếng dán kính iPhone 13 Pro Max JCPAL', 1
EXEC sp_AddHD @maHD_, N'Hồ Minh Ngọc', N'vũ thanh long', N'Ốp lưng iPhone 13 Silicon OSMIA Cam', 1
EXEC sp_AddHD @maHD_, N'Hồ Minh Ngọc', N'vũ thanh long', N'Samsung Galaxy Z Fold3 5G 512GB', 1
EXEC sp_AddHD @maHD_, N'Hồ Minh Ngọc', N'vũ thanh long', N'Pin sạc dự phòng Polymer 10.000 mAh Type C PD Samsung EB-P3300', 1
UPDATE HOADON set NGTAO = '7/27/2020' WHERE ID = @maHD_

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Lê Hồng Đào', N'Trần Vũ', N'iPhone 13 Pro Max 1TB', 1
EXEC sp_AddHD @maHD_, N'Lê Hồng Đào', N'Trần Vũ', N'Miếng dán kính iPhone 13 Pro Max JCPAL', 1
EXEC sp_AddHD @maHD_, N'Lê Hồng Đào', N'Trần Vũ', N'Ốp lưng iPhone 13 Silicon OSMIA Cam', 1
EXEC sp_AddHD @maHD_, N'Lê Hồng Đào', N'Trần Vũ', N'Samsung Galaxy Z Flip3 5G 256GB', 1
EXEC sp_AddHD @maHD_, N'Lê Hồng Đào', N'Trần Vũ', N'Pin sạc dự phòng Polymer 10.000 mAh Type C Xiaomi Power Bank 3 Ultra Compact', 2
UPDATE HOADON set NGTAO = '8/11/2020' WHERE ID = @maHD_

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Nguyễn Văn Cao', N'Lý Tường', N'iPhone 13 mini 256GB', 1
EXEC sp_AddHD @maHD_, N'Nguyễn Văn Cao', N'Lý Tường', N'iPhone 13 Pro Max 1TB', 1
EXEC sp_AddHD @maHD_, N'Nguyễn Văn Cao', N'Lý Tường', N'Miếng dán kính iPhone 13 Pro Max JCPAL', 2
EXEC sp_AddHD @maHD_, N'Nguyễn Văn Cao', N'Lý Tường', N'Ốp lưng iPhone 13 Silicon OSMIA Cam', 2
EXEC sp_AddHD @maHD_, N'Nguyễn Văn Cao', N'Lý Tường', N'Pin sạc dự phòng Polymer 10.000 mAh Type C Xiaomi Power Bank 3 Ultra Compact', 1
UPDATE HOADON set NGTAO = '9/2/2020' WHERE ID = @maHD_

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Lê Hồng Đào', N'Trần Vũ', N'iPhone XR 128GB', 1
EXEC sp_AddHD @maHD_, N'Lê Hồng Đào', N'Trần Vũ', N'Túi chống nước Cosano 5 inch Vàng Chanh', 1
EXEC sp_AddHD @maHD_, N'Lê Hồng Đào', N'Trần Vũ', N'Miếng dán kính iPhone 13 Pro Max JCPAL', 2
EXEC sp_AddHD @maHD_, N'Lê Hồng Đào', N'Trần Vũ', N'Ốp lưng iPhone 13 Silicon OSMIA Cam', 2
EXEC sp_AddHD @maHD_, N'Lê Hồng Đào', N'Trần Vũ', N'Pin sạc dự phòng Polymer 10.000 mAh Type C Xiaomi Power Bank 3 Ultra Compact', 1
UPDATE HOADON set NGTAO = '9/21/2020' WHERE ID = @maHD_

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Hồ Minh Ngọc', N'Đỗ Gia Nguyên', N'Xiaomi Redmi Note 9', 1
EXEC sp_AddHD @maHD_, N'Hồ Minh Ngọc', N'Đỗ Gia Nguyên', N'iPhone 13 Pro Max 1TB', 1
EXEC sp_AddHD @maHD_, N'Hồ Minh Ngọc', N'Đỗ Gia Nguyên', N'Miếng dán kính iPhone 13 Pro Max JCPAL', 1
EXEC sp_AddHD @maHD_, N'Hồ Minh Ngọc', N'Đỗ Gia Nguyên', N'Ốp lưng iPhone 13 Silicon OSMIA Cam', 1
EXEC sp_AddHD @maHD_, N'Hồ Minh Ngọc', N'Đỗ Gia Nguyên', N'Túi chống nước Cosano JMG-C-21 Xanh biển', 2
EXEC sp_AddHD @maHD_, N'Hồ Minh Ngọc', N'Đỗ Gia Nguyên', N'Pin sạc dự phòng Polymer 10.000 mAh Type C PD Samsung EB-P3300', 2
UPDATE HOADON set NGTAO = '10/27/2020' WHERE ID = @maHD_

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Huỳnh Ái Linh', N'Đỗ Gia Nguyên', N'iPhone 13 mini 256GB', 2
EXEC sp_AddHD @maHD_, N'Huỳnh Ái Linh', N'Đỗ Gia Nguyên', N'Xiaomi Redmi Note 9', 1
EXEC sp_AddHD @maHD_, N'Huỳnh Ái Linh', N'Đỗ Gia Nguyên', N'Ốp lưng iPhone 13 Silicon OSMIA Cam', 1
EXEC sp_AddHD @maHD_, N'Huỳnh Ái Linh', N'Đỗ Gia Nguyên', N'Túi chống nước Cosano JMG-C-21 Xanh biển', 2
EXEC sp_AddHD @maHD_, N'Huỳnh Ái Linh', N'Đỗ Gia Nguyên', N'Pin sạc dự phòng Polymer 10.000 mAh Type C PD Samsung EB-P3300', 2
UPDATE HOADON set NGTAO = '11/22/2020' WHERE ID = @maHD_

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Lý Gia Huy', N'Lê Đức Tài', N'iPhone 13 mini 256GB', 1
EXEC sp_AddHD @maHD_, N'Lý Gia Huy', N'Lê Đức Tài', N'Xiaomi Redmi Note 9', 1
EXEC sp_AddHD @maHD_, N'Lý Gia Huy', N'Lê Đức Tài', N'Vivo V20 SE', 1
EXEC sp_AddHD @maHD_, N'Lý Gia Huy', N'Lê Đức Tài', N'Ốp lưng iPhone 13 Silicon OSMIA Cam', 1
EXEC sp_AddHD @maHD_, N'Lý Gia Huy', N'Lê Đức Tài', N'Túi chống nước Cosano JMG-C-21 Xanh biển', 3
EXEC sp_AddHD @maHD_, N'Lý Gia Huy', N'Lê Đức Tài', N'Pin sạc dự phòng Polymer 10.000 mAh Type C PD Samsung EB-P3300', 2
UPDATE HOADON set NGTAO = '12/2/2020' WHERE ID = @maHD_

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Lý Gia Huy', N'Lê Đức Tài', N'iPhone 13 mini 256GB', 1
EXEC sp_AddHD @maHD_, N'Lý Gia Huy', N'Lê Đức Tài', N'Xiaomi Redmi Note 9', 1
EXEC sp_AddHD @maHD_, N'Lý Gia Huy', N'Lê Đức Tài', N'Ốp lưng iPhone 13 Silicon OSMIA Cam', 1
EXEC sp_AddHD @maHD_, N'Lý Gia Huy', N'Lê Đức Tài', N'Túi chống nước Cosano JMG-C-21 Xanh biển', 3
EXEC sp_AddHD @maHD_, N'Lý Gia Huy', N'Lê Đức Tài', N'Pin sạc dự phòng Polymer 10.000 mAh Type C PD Samsung EB-P3300', 2
UPDATE HOADON set NGTAO = '12/21/2020' WHERE ID = @maHD_

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Lê Thị Linh', N'Đỗ Gia Nguyên', N'iPhone XR 128GB', 1
EXEC sp_AddHD @maHD_, N'Lê Thị Linh', N'Đỗ Gia Nguyên', N'Pin sạc dự phòng Polymer 20.000 mAh Type C PD Energizer UE20011PQ', 1
EXEC sp_AddHD @maHD_, N'Lê Thị Linh', N'Đỗ Gia Nguyên', N'iPhone 13 Pro Max 1TB', 1
UPDATE HOADON set NGTAO = '1/12/2021' WHERE ID = @maHD_

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Cao Gia Vinh', N'Từ Huệ Sơn', N'iPhone XR 128GB', 1
EXEC sp_AddHD @maHD_, N'Cao Gia Vinh', N'Từ Huệ Sơn', N'Pin sạc dự phòng Polymer 20.000 mAh Type C PD Energizer UE20011PQ', 1
EXEC sp_AddHD @maHD_, N'Cao Gia Vinh', N'Từ Huệ Sơn', N'iPhone 13 Pro Max 1TB', 1
UPDATE HOADON set NGTAO = '1/13/2021' WHERE ID = @maHD_

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Cao Gia Vinh', N'Đỗ Gia Nguyên', N'iPhone XR 128GB', 1
EXEC sp_AddHD @maHD_, N'Cao Gia Vinh', N'Đỗ Gia Nguyên', N'iPhone 12 64GB', 1
EXEC sp_AddHD @maHD_, N'Cao Gia Vinh', N'Đỗ Gia Nguyên', N'Vivo Y21', 2
UPDATE HOADON set NGTAO = '2/2/2021' WHERE ID = @maHD_

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Nguyễn Thị Thương', N'Từ Huệ Sơn', N'OPPO Reno6 Z 5G', 1
EXEC sp_AddHD @maHD_, N'Nguyễn Thị Thương', N'Từ Huệ Sơn', N'Gậy chụp ảnh Bluetooth Tripod Xmobile K06 Đen', 3
EXEC sp_AddHD @maHD_, N'Nguyễn Thị Thương', N'Từ Huệ Sơn', N'Vivo Y21', 2
UPDATE HOADON set NGTAO = '2/21/2021' WHERE ID = @maHD_

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Hồ Minh Ngọc', N'Lê Đức Tài', N'iPhone 13 Pro Max 512GB', 1
EXEC sp_AddHD @maHD_, N'Hồ Minh Ngọc', N'Lê Đức Tài', N'Pin sạc dự phòng Polymer 10.000 mAh Type C PD Samsung EB-P3300', 1
EXEC sp_AddHD @maHD_, N'Hồ Minh Ngọc', N'Lê Đức Tài', N'iPhone 13 Pro 1TB', 1
UPDATE HOADON set NGTAO = '2/22/2021' WHERE ID = @maHD_

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Lý Gia Huy', N'Nguyễn văn Tèo', N'iPhone 13 Pro Max 512GB', 1
EXEC sp_AddHD @maHD_, N'Lý Gia Huy', N'Nguyễn văn Tèo', N'Realme 8 Pro Vàng Rực Rỡ', 1
EXEC sp_AddHD @maHD_, N'Lý Gia Huy', N'Nguyễn văn Tèo', N'Cáp Type-C 1.2 m Energizer C41C2AGBKT Đen', 1
UPDATE HOADON set NGTAO = '3/3/2021' WHERE ID = @maHD_

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Nguyễn Văn Cao', N'Nguyễn văn Tèo', N'iPhone 13 Pro Max 512GB', 1
EXEC sp_AddHD @maHD_, N'Nguyễn Văn Cao', N'Nguyễn văn Tèo', N'Nokia 3.4', 1
EXEC sp_AddHD @maHD_, N'Nguyễn Văn Cao', N'Nguyễn văn Tèo', N'Cáp Type-C 1.2 m Energizer C41C2AGBKT Đen', 1
EXEC sp_AddHD @maHD_, N'Nguyễn Văn Cao', N'Nguyễn văn Tèo', N'Pin sạc dự phòng Polymer 10.000 mAh Type C PD Samsung EB-P3300', 1
UPDATE HOADON set NGTAO = '3/23/2021' WHERE ID = @maHD_

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Huỳnh Ái Linh', N'Lê Đức Tài', N'Samsung Galaxy Z Flip3 5G 256GB', 2
EXEC sp_AddHD @maHD_, N'Huỳnh Ái Linh', N'Lê Đức Tài', N'Samsung Galaxy A03s', 1
EXEC sp_AddHD @maHD_, N'Huỳnh Ái Linh', N'Lê Đức Tài', N'iPhone 13 Pro 1TB', 1
EXEC sp_AddHD @maHD_, N'Huỳnh Ái Linh', N'Lê Đức Tài', N'iPhone 13 Pro Max 512GB', 1
EXEC sp_AddHD @maHD_, N'Huỳnh Ái Linh', N'Lê Đức Tài', N'Cáp Type-C 1.2 m Energizer C41C2AGBKT Đen', 1
UPDATE HOADON set NGTAO = '4/22/2021' WHERE ID = @maHD_

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Nguyễn Thị Thương', N'Từ Huệ Sơn', N'iPhone 13 Pro 1TB', 2
EXEC sp_AddHD @maHD_, N'Nguyễn Thị Thương', N'Từ Huệ Sơn', N'Realme 6 Pro', 1
EXEC sp_AddHD @maHD_, N'Nguyễn Thị Thương', N'Từ Huệ Sơn', N'Pin sạc dự phòng Polymer 10.000 mAh Type C Xiaomi Power Bank 3 Ultra Compact', 2
EXEC sp_AddHD @maHD_, N'Nguyễn Thị Thương', N'Từ Huệ Sơn', N'Samsung Galaxy A03s', 2
UPDATE HOADON set NGTAO = '5/12/2021' WHERE ID = @maHD_

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Trần Ngọc Sang', N'Lê Đức Tài', N'Adapter Sạc Type C PD 25W Samsung EP-TA800N', 1
EXEC sp_AddHD @maHD_, N'Trần Ngọc Sang', N'Lê Đức Tài', N'Samsung Galaxy Z Fold3 5G 512GB', 1
EXEC sp_AddHD @maHD_, N'Trần Ngọc Sang', N'Lê Đức Tài', N'OPPO Reno6 Z 5G', 1
UPDATE HOADON set NGTAO = '6/14/2021' WHERE ID = @maHD_

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Lý Gia Huy', N'Nguyễn văn Tèo', N'Adapter Sạc Type C PD 25W Samsung EP-TA800N', 1
EXEC sp_AddHD @maHD_, N'Lý Gia Huy', N'Nguyễn văn Tèo', N'Samsung Galaxy Z Fold3 5G 512GB', 1
EXEC sp_AddHD @maHD_, N'Lý Gia Huy', N'Nguyễn văn Tèo', N'iPhone 13 Pro 1TB', 1
UPDATE HOADON set NGTAO = '6/20/2021' WHERE ID = @maHD_

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Nguyễn Thị Thương', N'Trần Vũ', N'Samsung Galaxy Z Flip3 5G 256GB', 1
EXEC sp_AddHD @maHD_, N'Nguyễn Thị Thương', N'Trần Vũ', N'iPhone 13 Pro Max 512GB', 1
EXEC sp_AddHD @maHD_, N'Nguyễn Thị Thương', N'Trần Vũ', N'Ốp lưng iPhone 13 Silicon OSMIA Cam', 1
EXEC sp_AddHD @maHD_, N'Nguyễn Thị Thương', N'Trần Vũ', N'Dây đeo điện thoại OSMIA silicon CRS', 3
UPDATE HOADON set NGTAO = '7/12/2021' WHERE ID = @maHD_

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Huỳnh Ái Linh', N'Lê Đức Tài', N'Vivo Y21', 1
EXEC sp_AddHD @maHD_, N'Huỳnh Ái Linh', N'Lê Đức Tài', N'Xiaomi 11 Lite 5G NE', 1
EXEC sp_AddHD @maHD_, N'Huỳnh Ái Linh', N'Lê Đức Tài', N'Ốp lưng iPhone 13 Silicon OSMIA Cam', 1
EXEC sp_AddHD @maHD_, N'Huỳnh Ái Linh', N'Lê Đức Tài', N'Dây đeo điện thoại OSMIA silicon CRS', 1
UPDATE HOADON set NGTAO = '7/21/2021' WHERE ID = @maHD_

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Đỗ Ái Vy', N'Trần Vũ', N'Samsung Galaxy M51', 2
EXEC sp_AddHD @maHD_, N'Đỗ Ái Vy', N'Trần Vũ', N'iPhone 13 Pro Max 512GB', 1
EXEC sp_AddHD @maHD_, N'Đỗ Ái Vy', N'Trần Vũ', N'Nokia 6300 4G', 2
UPDATE HOADON set NGTAO = '8/12/2021' WHERE ID = @maHD_

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Lý Gia Huy', N'Lý Tường', N'Samsung Galaxy Z Flip3 5G 256GB', 2
EXEC sp_AddHD @maHD_, N'Lý Gia Huy', N'Lý Tường', N'Pin sạc dự phòng Polymer 10.000mAh Type C Fast Charge Xiaomi Mi Power Bank 3', 1
EXEC sp_AddHD @maHD_, N'Lý Gia Huy', N'Lý Tường', N'Xiaomi Redmi Note 10S', 1
EXEC sp_AddHD @maHD_, N'Lý Gia Huy', N'Lý Tường', N'Cáp Type-C 1.2 m Energizer C41C2AGBKT Đen', 2
EXEC sp_AddHD @maHD_, N'Lý Gia Huy', N'Lý Tường', N'Nokia 6300 4G', 2
UPDATE HOADON set NGTAO = '8/19/2021' WHERE ID = @maHD_

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Cao Gia Vinh', N'Lê Đức Tài', N'Samsung Galaxy Z Flip3 5G 256GB', 1
EXEC sp_AddHD @maHD_, N'Cao Gia Vinh', N'Lê Đức Tài', N'Samsung Galaxy M51', 2
EXEC sp_AddHD @maHD_, N'Cao Gia Vinh', N'Lê Đức Tài', N'Túi chống nước Cosano 5 inch Vàng Chanh', 1
EXEC sp_AddHD @maHD_, N'Cao Gia Vinh', N'Lê Đức Tài', N'Cáp Type-C 1.2 m Energizer C41C2AGBKT Đen', 1
EXEC sp_AddHD @maHD_, N'Cao Gia Vinh', N'Lê Đức Tài', N'Pin sạc dự phòng Polymer 10.000mAh Type C Fast Charge Xiaomi Mi Power Bank 3', 1
UPDATE HOADON set NGTAO = '9/13/2021' WHERE ID = @maHD_

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Đỗ Ái Vy', N'Trần Vũ', N'Samsung Galaxy A03s', 2
EXEC sp_AddHD @maHD_, N'Đỗ Ái Vy', N'Trần Vũ', N'Xiaomi Redmi Note 9', 1
EXEC sp_AddHD @maHD_, N'Đỗ Ái Vy', N'Trần Vũ', N'Samsung Galaxy Z Flip3 5G 256GB', 1
EXEC sp_AddHD @maHD_, N'Đỗ Ái Vy', N'Trần Vũ', N'Cáp Type-C 1.2 m Energizer C41C2AGBKT Đen', 1
EXEC sp_AddHD @maHD_, N'Đỗ Ái Vy', N'Trần Vũ', N'Pin sạc dự phòng Polymer 10.000mAh Type C Fast Charge Xiaomi Mi Power Bank 3', 2
UPDATE HOADON set NGTAO = '9/23/2021' WHERE ID = @maHD_

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Lê Hồng Đào', N'Lê Đức Tài', N'Masstel Fami P20', 1
EXEC sp_AddHD @maHD_, N'Lê Hồng Đào', N'Lê Đức Tài', N'iPhone 13 mini 256GB', 1
EXEC sp_AddHD @maHD_, N'Lê Hồng Đào', N'Lê Đức Tài', N'Mobell Rock 3', 1
EXEC sp_AddHD @maHD_, N'Lê Hồng Đào', N'Lê Đức Tài', N'Xiaomi Redmi Note 9', 2
EXEC sp_AddHD @maHD_, N'Lê Hồng Đào', N'Lê Đức Tài', N'Gậy Chụp Ảnh Osmia OW5', 1
EXEC sp_AddHD @maHD_, N'Lê Hồng Đào', N'Lê Đức Tài', N'Dây đeo điện thoại OSMIA silicon CRS', 3
UPDATE HOADON set NGTAO = '10/22/2021' WHERE ID = @maHD_

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Nguyễn Thị Thương', N'vũ thanh long', N'Vivo X70 Pro 5G', 1
EXEC sp_AddHD @maHD_, N'Nguyễn Thị Thương', N'vũ thanh long', N'iPhone 13 Pro 1TB', 1
EXEC sp_AddHD @maHD_, N'Nguyễn Thị Thương', N'vũ thanh long', N'Mobell Rock 3', 1
EXEC sp_AddHD @maHD_, N'Nguyễn Thị Thương', N'vũ thanh long', N'Xiaomi Redmi Note 9', 1
EXEC sp_AddHD @maHD_, N'Nguyễn Thị Thương', N'vũ thanh long', N'Gậy Chụp Ảnh Osmia OW5', 1
EXEC sp_AddHD @maHD_, N'Nguyễn Thị Thương', N'vũ thanh long', N'Dây đeo điện thoại OSMIA silicon CRS', 2
UPDATE HOADON set NGTAO = '10/23/2021' WHERE ID = @maHD_

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Nguyễn Văn Cao', N'Từ Huệ Sơn', N'Vivo X70 Pro 5G', 2
EXEC sp_AddHD @maHD_, N'Nguyễn Văn Cao', N'Từ Huệ Sơn', N'iPhone XR 128GB', 2
EXEC sp_AddHD @maHD_, N'Nguyễn Văn Cao', N'Từ Huệ Sơn', N'Bộ 2 móc điện thoại OSMIA CK-CRS10 Mèo cá heo xanh', 1
EXEC sp_AddHD @maHD_, N'Nguyễn Văn Cao', N'Từ Huệ Sơn', N'Túi chống nước Cosano JMG-C-20 Xanh lá', 2
EXEC sp_AddHD @maHD_, N'Nguyễn Văn Cao', N'Từ Huệ Sơn', N'Gậy chụp ảnh Bluetooth Tripod Xmobile K06 Đen', 2
UPDATE HOADON set NGTAO = '11/11/2021' WHERE ID = @maHD_

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Cao Gia Vinh', N'Từ Huệ Sơn', N'iPhone 12 64GB', 1
EXEC sp_AddHD @maHD_, N'Cao Gia Vinh', N'Từ Huệ Sơn', N'Bộ 2 móc điện thoại OSMIA CK-CRS10 Mèo cá heo xanh', 1
EXEC sp_AddHD @maHD_, N'Cao Gia Vinh', N'Từ Huệ Sơn', N'Túi chống nước Cosano JMG-C-20 Xanh lá', 2
EXEC sp_AddHD @maHD_, N'Cao Gia Vinh', N'Từ Huệ Sơn', N'Gậy chụp ảnh Bluetooth Tripod Xmobile K06 Đen', 2
UPDATE HOADON set NGTAO = '11/21/2021' WHERE ID = @maHD_

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Huỳnh Ái Linh', N'Lý Tường', N'iPhone 12 64GB', 2
EXEC sp_AddHD @maHD_, N'Huỳnh Ái Linh', N'Lý Tường', N'Sạc không dây xe hơi 20W Xiaomi GDS4127GL Đen', 1
EXEC sp_AddHD @maHD_, N'Huỳnh Ái Linh', N'Lý Tường', N'Pin sạc dự phòng Polymer 20.000 mAh Type C PD Energizer UE20011PQ', 1
EXEC sp_AddHD @maHD_, N'Huỳnh Ái Linh', N'Lý Tường', N'Túi chống nước Cosano JMG-C-20 Xanh lá', 3
UPDATE HOADON set NGTAO = '12/2/2021' WHERE ID = @maHD_

EXEC sp_GetMaHD @maHD_ OUTPUT
EXEC sp_AddHD @maHD_, N'Nguyễn Thị Thương', N'vũ thanh long', N'iPhone 13 Pro Max 1TB', 2
EXEC sp_AddHD @maHD_, N'Nguyễn Thị Thương', N'vũ thanh long', N'Ốp lưng iPhone 13 Silicon OSMIA Cam', 2
EXEC sp_AddHD @maHD_, N'Nguyễn Thị Thương', N'vũ thanh long', N'Sạc không dây xe hơi 20W Xiaomi GDS4127GL Đen', 1
EXEC sp_AddHD @maHD_, N'Nguyễn Thị Thương', N'vũ thanh long', N'Pin sạc dự phòng Polymer 20.000 mAh Type C PD Energizer UE20011PQ', 2
EXEC sp_AddHD @maHD_, N'Nguyễn Thị Thương', N'vũ thanh long', N'Túi chống nước Cosano JMG-C-20 Xanh lá', 3
UPDATE HOADON set NGTAO = '12/21/2021' WHERE ID = @maHD_

------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
-------------------------------------    DEBUG     ---------------------------------------------------
------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
/* 
SELECT * FROM SANPHAM
update SANPHAM set hinhanh='' where id = 'sp078'
SELECT * FROM CauHinh
SELECT * FROM danhmuc
select * from loaisp
SELECT * FROM HOADON
SELECT * FROM CHITIETHD
SELECT * FROM DONGIA
select * from thongtintaikhoan
select * from KHACHHANG
select * from nhanvien

select * from thongtintaikhoan join khachhang on thongtintaikhoan.id_TaiKhoan=khachhang.id_tk

select * from sanpham join cauhinh on cauhinh.id_SP=sanpham.id

select * from taikhoan
select * from nhanvien nv join taikhoan tk on nv.id_tk=tk.id join thongtintaikhoan tttk on tttk.id_taikhoan=tk.id

EXEC sp_UpTTTK 'NV001', N'Từ Huệ Sơn', '2-5-2001', N'nam', 'tuhueson@gmail.com', '0938252793', ''

EXEC sp_GetKhachHang

exec sp_CKAcc 'tuhueson', '123', N'Nhân Viên'
EXEC sp_ChangeAcc 'admin', '123', N'Admin'

select nv.id, tk.id idtk, hoten, tinhtrang, ngsinh, gtinh, ngtao, email, sdt, dchi from nhanvien nv join taikhoan tk on nv.id_tk=tk.id join thongtintaikhoan tttk on tttk.id_taikhoan=tk.id where hoten like '%T%'

tìm kiếm nhân viên
select nv.id, hoten, tinhtrang, ngsinh, gtinh, ngtao, email, sdt, dchi from nhanvien nv join taikhoan tk on nv.id_tk=tk.id join thongtintaikhoan tttk on tttk.id_taikhoan=tk.id where nv.id = 'nv001'

select * from sanpham join danhmuc on sanpham.id_danhmuc=danhmuc.id left join dongia on dongia.id_sp=sanpham.id where dongia.id=(select top 1 dg.id from dongia dg where dg.id_sp=sanpham.id order by dg.id desc)

delete taikhoan where username = 'abc'


select * from sanpham left join dongia on dongia.id_sp=sanpham.id where dongia.id=(select top 1 dg.id from dongia dg where dg.id_sp=sanpham.id)


REPORT
exec sp_ReportHD 2021

sp_ReportBill 'HD001', 153450000


select ngtao, sum(dongia) from hoadon where year(ngtao)=2020 group by ngtao

select * from KhachHang


sp_ChartSanPham 2021
sp_ChartNhanVien 2020
sp_ChartDoanhThu 2020

select * from hoadon
exec sp_CKUsername 's', N'Nhân Viên'
select * from sanpham
select * from danhmuc
		-------------------------------------- debug lấy đơn giá ---------------------------------------
		SELECT SUM(GIA)
		FROM DONGIA
			WHERE id_sp = 'sp001'
			GROUP BY NGCAPNHAT
			ORDER BY NGCAPNHAT DESC
			select * from dongia
		-------------------------------------- debug ---------------------------------------
*/
