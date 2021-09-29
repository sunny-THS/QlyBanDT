IF EXISTS(SELECT * FROM sys.databases WHERE name='QLDT_LK')
BEGIN
        DROP DATABASE QLDT_LK
END
CREATE DATABASE QLDT_LK
GO
USE QLDT_LK
GO

-- tạo bảng
CREATE TABLE TAIKHOAN (
    ID VARCHAR(15) NOT NULL, -- CREATE AUTO
    USERNAME VARCHAR(50), -- CHECK USERNAME THEO GROUP
    PW VARCHAR(100), -- MÃ HÓA + salt
    CONSTRAINT PK_TK PRIMARY KEY (ID)
)
-- GR ADMIN(00): CONTROL ALL
-- GR NHÂN VIÊN(01): HỖ TRỢ KHÁCH HÀNG XỬ LÝ ĐƠN HÀNG
-- GR KHÁCH HÀNG(02): NGƯỜI DÙNG
CREATE TABLE GRTK (
    ID INT IDENTITY NOT NULL,
    TEN VARCHAR(50), -- TÊN GR
    CODEGR CHAR(2),
    CONSTRAINT PK_GR PRIMARY KEY (ID) 
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
    ID_TAIKHOAN VARCHAR(15) REFERENCES TAIKHOAN(ID), -- có thể null khi là khách hàng
    ID_GR INT REFERENCES GRTK(ID),
    CONSTRAINT PK_TTTK PRIMARY KEY (ID)
)
CREATE TABLE KHACHHANG (
    ID VARCHAR(10) NOT NULL, -- CREATE AUTO
    ID_TTTK VARCHAR(20),
    CONSTRAINT PK_KH PRIMARY KEY (ID),
    CONSTRAINT FK_KH_TTTK FOREIGN KEY (ID_TTTK) REFERENCES THONGTINTAIKHOAN(ID)
)
CREATE TABLE NHANVIEN (
    ID VARCHAR(10) NOT NULL, -- CREATE AUTO
    ID_TTTK VARCHAR(20),
    CONSTRAINT PK_NV PRIMARY KEY (ID),
    CONSTRAINT FK_NV_TTTK FOREIGN KEY (ID_TTTK) REFERENCES THONGTINTAIKHOAN(ID)
)
CREATE TABLE LOAISP (
    ID VARCHAR(5) NOT NULL,
    TENLOAI NVARCHAR(50),
    CONSTRAINT PK_LSP PRIMARY KEY (ID)
)
CREATE TABLE SANPHAM (
    ID VARCHAR(10) NOT NULL, -- CREATE AUTO
    TENSP NVARCHAR(50), -- TÊN SẢN PHẨM
    MOTA NVARCHAR(MAX), -- MÔ TẢ
    SOLUONG INT, -- SỐ LƯỢNG TỒN KHO
    -- DONGIA FLOAT, -- ĐƠN GIÁ
    NSX NVARCHAR(30), -- NHÀ SẢN XUẤT
    ID_LOAI VARCHAR(5) REFERENCES LOAISP(ID),
    CONSTRAINT PK_SP PRIMARY KEY (ID)
)
CREATE TABLE KHUYENMAI (
    ID INT IDENTITY NOT NULL,
    GIATRI FLOAT, -- TÍNH THEO %
    THOIGIANBD DATETIME, -- THỜI GIAN BẮT ĐẦU
    THOIGIANKT DATETIME, -- THỜI GIAN KẾT THÚC
    ID_SP VARCHAR(10) NOT NULL REFERENCES SANPHAM(ID),
    CONSTRAINT PK_MK PRIMARY KEY (ID, ID_SP)
)
CREATE TABLE DONGIA (
    ID INT IDENTITY NOT NULL,
    ID_SP VARCHAR(10) NOT NULL REFERENCES SANPHAM(ID),
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
    ID_SP VARCHAR(10) REFERENCES SANPHAM(ID),
    SOLUONG INT, -- SỐ LƯỢNG > 0
    CONSTRAINT PK_CTHD PRIMARY KEY (ID, ID_HD) 
)
GO