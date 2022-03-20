-- insert, 행 추가하기
-- INSERT INTO table_name(column1, column2, ...) VALUES (value1, value2, ...),(value4,value5, ...);

-- delete, 행 삭제하기
-- DELETE FROM table_name WHERE some_column = some_value

-- update, 데이터 갱신하기
-- UPDATE table_name SET column_name = 'new value' WHERE condition;
-- EX) UPDATE product SET 원가 = 70,000, 카테고리 = '피트니스' WHERE 상품 번호 = 'a002';

-- procedure
-- DELIMITER // CREATE PROCEDURE 프로시저 명() BEGIN 쿼리; END // DELIMITER;
-- EX) DELIMITER // CREATE PROCEDURE sales_minus() BEGIN UPDATE product SET 원가 = (-1)*원가 WHERE `취소 여부` ='Y' AND `판매 일자` = CURDATE() -1; END // DELIMITER;

-- VIEW
-- SELECT 주문 번호 FROM DB.SALES WHERE 취소 여부 ='Y';
-- CREATE VIEW DB.view_name AS SELECT-STATEMENT;
-- EX) CREATE VIEW DB.cancel_prodno AS SELECT 주문 번호 FROM DB.SALES WHERE 취소 여부 = 'Y';
-- 생성된 VIEW는 테이블과 동일하게 사용 가능
-- EX) SELECT * FROM DB.cancel_prodno;


 