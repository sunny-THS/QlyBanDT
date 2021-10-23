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
    ID_TAIKHOAN VARCHAR(15) REFERENCES TAIKHOAN(ID),
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
    CONSTRAINT PK_NV PRIMARY KEY (ID),
    CONSTRAINT FK_NV_TK FOREIGN KEY (ID_TK) REFERENCES TAIKHOAN(ID)
)
CREATE TABLE DANHMUC (
    ID INT IDENTITY NOT NULL,
    TENDANHMUC NVARCHAR(50),
    CONSTRAINT PK_DMUC PRIMARY KEY (ID)
)
CREATE TABLE LOAISP ( 
    ID VARCHAR(6) NOT NULL,
    TENLOAI NVARCHAR(50), -- android, iphone, điện thoại phổ thông
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
    ID_DANHMUC INT REFERENCES DANHMUC(ID),
    ID_HANG INT REFERENCES HANG(ID), -- HÃNG SP
    CONSTRAINT PK_SP PRIMARY KEY (ID)
)
CREATE TABLE CAUHINH (
    ID INT IDENTITY NOT NULL,
    ID_SP VARCHAR(5) REFERENCES SANPHAM(ID),
    TENCAUHINH NVARCHAR(30),
    NOIDUNGCAUHINH NVARCHAR(40),
    CONSTRAINT PK_CH PRIMARY KEY (ID)
)
CREATE TABLE SALE (
    ID INT IDENTITY NOT NULL,
    GIATRI FLOAT, -- GIÁ TRỊ SALE
    ID_SP VARCHAR(5) REFERENCES SANPHAM(ID),
    NGCAPNHAT DATETIME, -- NGÀY CẬP NHẬT SALE LẤY NGÀY GẦN NHẤT
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
    DONGIA FLOAT, -- TỔNG (SỐ LƯỢNG * ĐƠN GIÁ)
    TINHTRANG NVARCHAR(50), -- CHƯA GIAO, ĐÃ GIAO
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
    ID_KH VARCHAR(10) REFERENCES KHACHHANG(ID),
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

CREATE PROC sp_AddLSP -- THÊM LOẠI SP
@tenLSP NVARCHAR(50)
AS 
    BEGIN TRY
        IF EXISTS(SELECT * FROM LOAISP WHERE ID = (SELECT ID FROM LOAISP WHERE TENLOAI = @tenLSP))
			THROW 51000, N'Loại sản phẩm đã tồn tại.', 1;

		INSERT LOAISP(TENLOAI)
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
@tenLSP NVARCHAR(50),
@tenDanhMuc NVARCHAR(50)
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

        DECLARE @idDanhMuc INT
        SELECT @idDanhMuc = ID FROM DANHMUC WHERE TENDANHMUC = @tenDanhMuc
		
		INSERT SANPHAM(ID, TENSP, SOLUONG, NSX, HINHANH, ID_LOAI, ID_HANG, ID_DANHMUC)
		VALUES (@IDSP, @tenSP, @soLuong, @nxs, @urlImage, @IDLSP, @IDHANG, @idDanhMuc)

		INSERT DONGIA(ID_SP, GIA)
		VALUES (@IDSP, @gia)
	END TRY
	BEGIN CATCH
		EXEC sp_GetErrorInfo;
	END CATCH
GO

CREATE PROC sp_AddCauHinh
@tenSP NVARCHAR(Max),
@tenCH NVARCHAR(30),
@noiDungCH NVARCHAR(40)
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
ADD CONSTRAINT DF_ID_NV DEFAULT DBO.fn_autoIDNV() FOR ID

ALTER TABLE HOADON 
ADD CONSTRAINT DF_NGTAO_HD DEFAULT GETDATE() FOR NGTAO,
    CONSTRAINT DF_TT DEFAULT N'CHƯA GIAO' FOR TINHTRANG,
    CONSTRAINT DF_ID DEFAULT DBO.fn_autoIDHD() FOR ID

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
EXEC sp_AddAcc 'admin', 'admin@123456789', N'ADMIN', N'Admin', '2-5-2001', N'nam', 'admin@gmail.com', '000000000', null
EXEC sp_AddAcc 'tuhueson', 'tuhueson@123456789', N'Nhân viên', N'Từ Huệ Sơn', '2-5-2001', N'nam', 'tuhueson@gmail.com', '000000000', null
EXEC sp_AddAcc 'leductai', 'leductai@123456789', N'Nhân viên', N'Lê Đức Tài', '12-4-2001', N'nam', 'leductai@gmail.com', '000000000', null
EXEC sp_AddAcc '', '', N'Khách hàng', N'Khách hàng 1', '12-4-2001', N'nam', 'khachHang@gmail.com', '000000000', null

-- BẢNG DANH MỤC
INSERT DANHMUC SELECT N'Điện Thoại'
INSERT DANHMUC SELECT N'Tablet'
INSERT DANHMUC SELECT N'Phụ kiện'

-- BẢNG LOẠI SẢN PHẨM
EXEC sp_AddLSP N'Android'
EXEC sp_AddLSP N'iPhone(iOS)'
EXEC sp_AddLSP N'Điện thoại phổ thông'

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
EXEC sp_AddSP N'iPhone 12 64GB', N'iPhone', 20, 20490000, null, 'iPhone12_64.jpg', N'iPhone(iOS)', N'Điện Thoại' --
EXEC sp_AddSP N'iPhone 13 Pro Max 1TB', N'iPhone', 20, 49990000, null, 'iPhone13ProMax_1.jpg', N'iPhone(iOS)', N'Điện Thoại' --
EXEC sp_AddSP N'iPhone 13 Pro 1TB', N'iPhone', 20, 46990000, null, 'iPhone13Pro_1.jpg', N'iPhone(iOS)', N'Điện Thoại' --
EXEC sp_AddSP N'iPhone 13 Pro Max 512GB', N'iPhone', 20, 43990000, null, 'iPhone13ProMax_512.jpg', N'iPhone(iOS)', N'Điện Thoại' --
EXEC sp_AddSP N'iPhone 13 Pro 512GB', N'iPhone', 20, 40990000, null, 'iPhone13Pro_512.jpg', N'iPhone(iOS)', N'Điện Thoại' --
EXEC sp_AddSP N'iPhone 12 Pro Max 512GB', N'iPhone', 20, 39990000, null, 'iPhone12Pro_512.jpg', N'iPhone(iOS)', N'Điện Thoại' --
EXEC sp_AddSP N'iPhone 13 mini 256GB', N'iPhone', 20, 24990000, null, 'iPhone13Mini_256.jpg', N'iPhone(iOS)', N'Điện Thoại' --
EXEC sp_AddSP N'iPhone 11 128GB', N'iPhone', 20, 18990000, null, 'iPhone11_128.jpg', N'iPhone(iOS)', N'Điện Thoại' --
EXEC sp_AddSP N'iPhone XR 128GB', N'iPhone', 20, 16490000, null, 'iPhoneXR_128.jpg', N'iPhone(iOS)', N'Điện Thoại'
EXEC sp_AddSP N'Samsung Galaxy Z Fold3 5G 512GB', N'SAMSUNG', 20, 16490000, null, 'iPhoneXR_128.jpg', N'Android', N'Điện Thoại'

-- Bảng cấu hình
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

select * from TAIKHOAN
select * from GRTK
EXEC sp_CKAcc 'tuhueson', 'tuhu4eson@123456789', N'Nhân Viên'
