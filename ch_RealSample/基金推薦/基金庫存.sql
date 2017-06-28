use project2017 
--------------------------�w�s -----------------------------------------
declare @YYYYMM varchar(6),@YYYY varchar(4)
set @YYYYMM=(select max(right(name,6)) from bank2017.dbo.sysobjects where xtype='V' and left(name,12)='v_CIFALL999_')
select @YYYYMM

exec source.dbo.up_droptable 'project2017.dbo.�������_�w�s����'
exec source.dbo.up_droptable 'project2017.dbo.[�������_�����������(�H)]'
exec source.dbo.up_droptable 'project2017.dbo.�������_�w�s��������έp'


select �����Ҧr��,
	����,
	[�����(�}�l)],
	�������W��,
	DB����,
	�۵M�H����
into #�������_�w�s����
from DB_WM.dbo.v_�w�s����s�q���R
where  YYYYMM = @YYYYMM 


-- where  DB���� = 'a.�@�먭��' and YYYYMM = @YYYYMM 
-- where DB���� = 'a.�@�먭��' and ��ꫬ�A = 'b.�浧����' and YYYYMM = @YYYYMM

-- exec sp_rename 'project2017.dbo.�������_�w�s����', 'project2017.dbo.�������_�w�s����_�۵M�H�浧����'
-- sp_rename '�������_�w�s����_�۵M�H','�������_�w�s����'
-- select top 10 * from  DB_WM.dbo.v_�w�s����s�q���R where DB����= 'a.�@�먭��'
-- select count(*) from project2017.dbo.�������_�w�s���� where [�����(�}�l)] >'20151231'  --85463
-- select count(distinct �����Ҧr��)  from project2017.dbo.�������_�w�s���� where [�����(�}�l)] >'20151231' 
-- select top 10 * from #�������_�w�s����
select �����Ҧr��,
	����,
	convert(varchar,[�����(�}�l)],112) [�����(�}�l)],
	convert(varchar(4),[�����(�}�l)],112) [����~(�}�l)],
	�������W��,
	DB����,
	�۵M�H����
into �������_�w�s����
from  #�������_�w�s����



go
----------------------- view --------------------------------
alter view v_�������_�w�s���� as 
select a.*,b.idn from �������_�w�s���� a
	left join source.dbo.idn b
		on a.�����Ҧr��=b.�����Ҧr��



select top 10 * from v_�������_�w�s���� where DB����= 'a.�@�먭��'

-- select top 10 * from v_�������_�w�s���� where left([����~(�}�l)],4) >= '2015'
-- select  distinct �����Ҧr�� from v_�������_�w�s���� where [����~(�}�l)] >= '2015'
------------------------------------------------------------------------



---�ư��������~ < 2015 --
--- ��������������� by �H --

select a.�����Ҧr��, a.�������W��,count(*) ������  
into #fund_no -- �������Ҽ�
from (select * from �������_�w�s���� where [����~(�}�l)] >2015) a
group by a.�����Ҧr��,a.�������W��

--1960�ɰ��
select count(distinct left(�������W��,3)) from #fund_no

-- 32570 user �w�s
select �����Ҧr��,
	count(*) �����������,
	sum(������) �������Ҽ�
-- into [�������_�����������(�H)]
from #fund_no
group by �����Ҧr��


select �������W��, count(*) �h�֤H����
-- into �������_�w�s��������έp
from #fund_no
group by �������W�� 
order by 2 desc
 
-- select �����������,count(*) number from  [�������_�����������(�H)] 
-- group by �����������
-- order by 1




------ �ͦ�������˲M���...����.... -----

exec source.dbo.up_droptable 'project2017.dbo.�������_���M��'

select 
	b.uid �����Ҧr��,
	c.�����������,
	c.�������Ҽ�,
	b.���ˤ�k,
	b.item1 ���˰��1,
	b.item2 ���˰��2,
	b.item3 ���˰��3,
	b.item4 ���˰��4,
	b.item5 ���˰��5,
	b.item6 ���˰��6,
	b.item7 ���˰��7,
	b.item8 ���˰��8,
	b.item9 ���˰��9,
	b.item10 ���˰��10,
	b.item11 ���˰��11,
	b.item12 ���˰��12,
	b.item13 ���˰��13,
	b.item14 ���˰��14,
	b.item15 ���˰��15,
	b.item16 ���˰��16,
	b.item17 ���˰��17,
	b.item18 ���˰��18,
	b.item19 ���˰��19,
	b.item20 ���˰��20
into �������_���M��
from (
select 'a.�������' ���ˤ�k, *  from dbo.�������_�������Top20 
union 
select 'b.�Τ�ۦ�' ���ˤ�k , * from �������_�ӤH���Top20 
) b
	left join [�������_�����������(�H)] c 
		on b.uid = c.�����Ҧr��


------ view ---- 

ALTER VIEW 
v_�������_���M��
as 
SELECT 
	*,
	CASE WHEN ����������� <3 THEN 'a.����1~3�ذ��'
		WHEN �����������<6 THEN 'b.����4~5�ذ��'
		WHEN �����������<11 THEN 'c.����6~10�ذ��'
		WHEN �����������<21 THEN 'd.����11~20�ذ��'
		WHEN �����������>20 THEN 'e.����>20�ذ��'
		ELSE 'f.���`' end as ��������ŶZ,
	CASE WHEN �������Ҽ� <3 THEN 'a.����1~3�������'
		WHEN �������Ҽ�<6 THEN 'b.����4~5�������'
		WHEN �������Ҽ�<11 THEN 'c.����6~10�������'
		WHEN �������Ҽ�<21 THEN 'd.����11~20�������'
		WHEN �������Ҽ�>20 THEN 'd.����>20�������'
		ELSE 'f.���`' end as ������ҼƯŶZ
FROM �������_���M��



---------------------------- ���հ� (�ݧR��) ------------------------------------------------
select distinct �������W�� from v_�������_���ʩ��� where ���ʵn���~>= 2015
select top 10 * from v_�������_���ʩ��� where ���ʵn���~>= 2015
select count(distinct ����) from v_�������_�w�s���� where [����~(�}�l)] >=2015

select ���ˤ�k, count(*) n from v_�������_���M��
group by ���ˤ�k
--2748 ����c�� --
select count(*) from external.dbo.MMA����򥻸��_�C�g��s
where convert(varchar(8),��s�ɶ�,112) = '20170322'
---
select top 100 * from v_�������_���M��

select * from �������_�w�s��������έp

select  count(*) n
from 
v_�������_���M��

select ��������ŶZ , count(*) n
from 
v_�������_���M��
group by ��������ŶZ


select * 
-- into #temp
from dbo.�������_����ۦ���_C
where left(���1,3) = '100'
order by �ۦ��� desc


select top 100 ���1,count(*) n 
-- into #temp2
from dbo.�������_����ۦ���_C
group by ���1
order by n desc

select * from dbo.�������_����ۦ���_J 
where 
-- ���1 in (select ���1 from #temp2) 
left(���1,3) = '213' order by �ۦ��� desc

select ���1,���2,max(�ۦ���) sim from �������_����ۦ���_C
where ���1 in (select ���1 from #temp2) 
group by ���1,���2
order by ���1,sim desc
-- order by max(�ۦ���)


-- jaccard �ۦ��� --

select * 
-- into #temp
from dbo.�������_����ۦ���_J
where left(���1,3) = '65M'
order by �ۦ��� desc


