---------------------------------- ������� --------------------------------------------------

use project2017
exec source.dbo.up_droptable 'project2017.dbo.�������_���ʩ���'

-- ���ʾ��v���(���ʵn���~��) 199403 �� 201512 -- �@680,244 ����
select max(���ʵn���~��) from db_wm.dbo.v_������ʦ��ڰl��h
select min(���ʵn���~��) from db_wm.dbo.v_������ʦ��ڰl��h
select count(distinct ����) from db_wm.dbo.v_������ʦ��ڰl��h

-- ���ʸ��h + now

select convert(varchar(4),���ʵn���~��,112) yyyy,
	�����Ҧr��,
	����,
	DB����,
	�������²��1 [�������W��],
	��ꫬ�A,
	�۵M�H����,
	count(*) �ʶR����
into #�������_���ک���
from db_wm.dbo.v_������ʦ��ڰl��h
group by �����Ҧr��,����,�������²��1,DB����,��ꫬ�A,convert(varchar(4),���ʵn���~��,112),�۵M�H����


select convert(varchar(4),���ʵn���~��,112) yyyy,
	�����Ҧr��,
	����,
	DB����,
	�������²��1 [�������W��],
	��ꫬ�A,
	�۵M�H����,
	count(*) �ʶR����
into #�������_���ک���2
from db_wm.dbo.v_������ʦ��ڰl��
group by �����Ҧr��,����,�������²��1,DB����,��ꫬ�A,convert(varchar(4),���ʵn���~��,112),�۵M�H����

select top 10 * from #�������_���ک��� where ����= '126V0111500160' -- �P�@����ƭY�����򦩴ڷ|�X�{�bh �M �{�b 
select top 10 * from #�������_���ک���2 where ����= '126V0111500160'

select a.yyyy ���ʵn���~,
	 a.�����Ҧr��,
	a.�������W��,
	a.����,
	a.DB����,
	a.��ꫬ�A,
	a.�۵M�H����,
	sum(a.�ʶR����) �ʶR���� 
into �������_���ʩ���
from 
(select  * from #�������_���ک���
union 
select * from #�������_���ک���2) a
group by yyyy,�����Ҧr��,��ꫬ�A,�������W��,����,DB����,�۵M�H����

------------------ view -------------------------------------

alter view  v_�������_���ʩ���  as 
select  a.*,b.idn from �������_���ʩ��� a
	left join source.dbo.idn b
		on a.�����Ҧr��=b.�����Ҧr��


------------------- �������(�۵M�H,>=2015�~���ʵn���~ ) -------------------------------

select distinct �����Ҧr�� from �������_���ʩ��� -- 112,144�H���������

select count(distinct �����Ҧr��) from �������_���ʩ��� where ���ʵn���~>='2015' --45,324
select count(distinct ����) from �������_���ʩ��� where ���ʵn���~>='2015' --45,324

-- �۵M�H���ʵn���~ >= 2015 
-- 214,528 
select * 
into �������_���ʩ���_2015
from �������_���ʩ��� where ���ʵn���~>='2015' and [�۵M�H����] = 'a.�۵M�H'
-- select ���ʵn���~ , count( distinct �����Ҧr��) �Τ��
-- from �������_���ʩ��� 
-- group by ���ʵn���~

------------------ ����S�x ��z ------------------------------


declare @YYYYMMDD varchar(8)
set @YYYYMMDD= (select max(convert(varchar(8), ��s�ɶ�,112)) from  external.dbo.MMA����򥻸��_�C�g��s)

-- drop table  project2017.dbo.�������_����ݩ�

select  
	a.��s�ɶ�,
	convert(varchar(8),��s�ɶ�,112) yyyymmdd,
	a.����N�X,
	b.�ꤺ�~������O,
	a.[����W��(�x��/��)],
	a.����ثe�W�Ұ϶�,
	a.������߮ɶ�,
	datediff(year,������߮ɶ�,��s�ɶ�) ������ߴX�~,
	b.������q�N�X,
	b.�p�����O,
	a.����g�z�H,
	b.�ϰ�O,
	a.�����겣�~����1,
	a.�����겣�~����2,
	a.�����겣�~����3,
	b.AUM������A�O,
	b.�ӫ~����ݩ�,
	b.�����q�ŵ��O,
	b.�O����������O,
	a.�b��,
	a.Sharpe,
	a.Beta,
	a.[�@�Ӥ�ֿn���S�v(%)],
	a.[�T�Ӥ�ֿn���S�v(%)],
	a.[���Ӥ�ֿn���S�v(%)],
	a.[�@�~�ֿn���S�v(%)],
	a.[�T�~�ֿn���S�v(%)],
	a.[���~�ֿn���S�v(%)],
	a.[�ۤ��~�H�ӳ��S�v(%)],
	a.[�ۦ��ߤ�_���S�v(%)],
	case when a.[�Ź��T�������]=0 then NULL
	else a.[�Ź��T�������] end as �������
into project2017.dbo.�������_����ݩ�
from external.dbo.MMA����򥻸��_�C�g��s a
	left join db_wm.dbo.v_fund b 
		on a.����N�X = b.����N�X
where convert(varchar(8),��s�ɶ�,112) = @YYYYMMDD


select top 10 * from project2017.dbo.�������_����ݩ� b 

--------------- ���������O ------------

select  distinct  �������W��, '0' [���������O]
into #temp_fund
from �������_���ʩ���_2015

delete from #temp_fund 
where �������W�� in (select top 20 �������W��
from �������_���ʩ���_2015
group by �������W��
order by count(����) desc)

select top 20 �������W��, 
	'1' [���������O]
-- 	count(����) ���Ҽ�
into #temp_hotfund
from �������_���ʩ���_2015
group by �������W��
order by count(����) desc 


select * 
into #�������_���������O
from #temp_fund
union all
select *,'1' ���������O from #temp_hotfund

select left(�������W��,3) [����N�X], 
	max(���������O) ���������O 
into �������_���������O
from #�������_���������O1
group by left(�������W��,3)
--- ----------------------------------- VIEW ----------------------------------------------------------------
alter view v_�������_������� as 
select a.*,b.*,
-- ��������ŶZ
	case when b.������� < 3 then 'a. [0.5,3)'	
		when b.������� <= 3 then 'b.[3,5]'
		else 'c.ND' end as ��������ŶZ,
-- 	 case when b.AUM������A�O='E' then 'a.�Ѳ���'
-- 		  when b.AUM������A�O='B' then 'b.�Ũ髬'
-- 		  when b.AUM������A�O='M' then 'c.�f����'
-- 		  when b.AUM������A�O in ('O','W','F','FT','I') then 'd.��L��' else 'ND' end as ���A�O,
	 case when b.AUM������A�O='E' then 'a.�Ѳ���'
		  when b.AUM������A�O='B' then 'b.�Ũ髬'
		  when b.AUM������A�O='M' then 'c.�f����'
		  when b.AUM������A�O='W' then 'd.���ū�'
		  when b.AUM������A�O='F' then 'e.�զX��'
		  when b.AUM������A�O='FT' then 'f.���f��'
		  when b.AUM������A�O='I' then 'g.���ƫ�'
		  when b.AUM������A�O='O' then 'h.��L��' else 'ND' end as AUM���A�O,
--- ���߮ɶ��ŶZ
	case when b.������ߴX�~<1 then 'a.<1�~'
		when b.������ߴX�~<2 then 'b.1(�t)~2�~' 
		when b.������ߴX�~<3 then 'c.2(�t)~3�~' 
		when b.������ߴX�~<5 then 'd.3(�t)~5�~' 
		when b.������ߴX�~<10 then 'e.5(�t)~10�~' 
		when b.������ߴX�~<15 then 'f.10(�t)~15�~' 
		when b.������ߴX�~<20 then 'g.15(�t)~20�~' 
		when b.������ߴX�~<30 then 'h.20(�t)~30�~' 
		when b.������ߴX�~<50 then 'i.30(�t)~50�~' 
		when b.������ߴX�~<100 then 'j.>50�~(�t)~' 
		else 'ND' end as [������߯ŶZ(�~)],
-- �ϰ�O
	case when b.�ϰ�O = 'TW' then 'TW.�x�W'
		when b.�ϰ�O = 'ZA' then 'ZA.�n�D'
		when b.�ϰ�O = 'BE' then 'BE.��Q��'
		when b.�ϰ�O = 'MY' then 'MY.���Ӧ��'
		when b.�ϰ�O = 'US' then 'US.����'
		when b.�ϰ�O = 'PH' then 'PH.��߻�'
		when b.�ϰ�O = 'HK' then 'HK.����'
		when b.�ϰ�O = 'AU' then 'AU.�D�w'
		when b.�ϰ�O = 'JP' then 'JP.�饻'
		when b.�ϰ�O = 'KR' then 'KR.����'			
		when b.�ϰ�O = 'IE' then 'IE.�R����'
		when b.�ϰ�O = 'CA' then 'CA.�[���j'
		when b.�ϰ�O = 'BR' then 'BR.�ڦ�'
		when b.�ϰ�O = 'IN' then 'IN.�L��'
		when b.�ϰ�O = 'CN' then 'CN.����'
		when b.�ϰ�O = 'GB' then 'GB.�^��'
		when b.�ϰ�O = 'DE' then 'DE.�w��'
		when b.�ϰ�O = 'ID' then 'ID.�L��'
		when b.�ϰ�O = 'CH' then 'CH.��h'
		when b.�ϰ�O = 'RU' then 'RU.�Xù��'
		when b.�ϰ�O = 'TH' then 'TH.����'
		when b.�ϰ�O = 'IT' then 'IT.�q�j�Q'
		when b.�ϰ�O = 'LU' then 'LU.���y��'
		when b.�ϰ�O = 'SG' then 'SG.�s�[�Y'
		when b.�ϰ�O = 'VN' then 'VN.�V�n'
		when b.�ϰ�O = 'FR' then 'FR.�k��'
		else 'ND' end as �ϰ�O1,
	d.���������O,
	c.idn,
	e.cluster
from �������_���ʩ���_2015 a
	left join project2017.dbo.�������_����ݩ� b 
		on left(a.�������W��,3) = b.����N�X
	left join source.dbo.idn c
		on a.�����Ҧr��=c.�����Ҧr��
	left join project2017.dbo.�������_���������O d
		on left(a.�������W��,3) = d.����N�X
	left join project2017.dbo.�������_������s e
		on d.����N�X = e.����N�X

select top 10 * from v_�������_�������
--------- ������profile --------

alter view v_�������_������ʰ�� as
select 
	e.���Ҽ�,
	b.*,
	case when b.�ϰ�O = 'TW' then 'TW.�x�W'
		when b.�ϰ�O = 'ZA' then 'ZA.�n�D'
		when b.�ϰ�O = 'BE' then 'BE.��Q��'
		when b.�ϰ�O = 'MY' then 'MY.���Ӧ��'
		when b.�ϰ�O = 'US' then 'US.����'
		when b.�ϰ�O = 'PH' then 'PH.��߻�'
		when b.�ϰ�O = 'HK' then 'HK.����'
		when b.�ϰ�O = 'AU' then 'AU.�D�w'
		when b.�ϰ�O = 'JP' then 'JP.�饻'
		when b.�ϰ�O = 'KR' then 'KR.����'			
		when b.�ϰ�O = 'IE' then 'IE.�R����'
		when b.�ϰ�O = 'CA' then 'CA.�[���j'
		when b.�ϰ�O = 'BR' then 'BR.�ڦ�'
		when b.�ϰ�O = 'IN' then 'IN.�L��'
		when b.�ϰ�O = 'CN' then 'CN.����'
		when b.�ϰ�O = 'GB' then 'GB.�^��'
		when b.�ϰ�O = 'DE' then 'DE.�w��'
		when b.�ϰ�O = 'ID' then 'ID.�L��'
		when b.�ϰ�O = 'CH' then 'CH.��h'
		when b.�ϰ�O = 'RU' then 'RU.�Xù��'
		when b.�ϰ�O = 'TH' then 'TH.����'
		when b.�ϰ�O = 'IT' then 'IT.�q�j�Q'
		when b.�ϰ�O = 'LU' then 'LU.���y��'
		when b.�ϰ�O = 'SG' then 'SG.�s�[�Y'
		when b.�ϰ�O = 'VN' then 'VN.�V�n'
		when b.�ϰ�O = 'FR' then 'FR.�k��'
		else 'ND' end as �ϰ�O1, 
	 case when b.AUM������A�O='E' then 'a.�Ѳ���'
		  when b.AUM������A�O='B' then 'b.�Ũ髬'
		  when b.AUM������A�O='M' then 'c.�f����'
		  when b.AUM������A�O='W' then 'd.���ū�'
		  when b.AUM������A�O='F' then 'e.�զX��'
		  when b.AUM������A�O='FT' then 'f.���f��'
		  when b.AUM������A�O='I' then 'g.���ƫ�'
		  when b.AUM������A�O='O' then 'h.��L��' else 'ND' end as AUM���A�O

from  �������_���������O c 
	left join project2017.dbo.�������_����ݩ� b 
		on c.����N�X = b.����N�X
	left join (select top 20 �������W��, count(����) ���Ҽ�
			from �������_���ʩ���_2015
				group by �������W��
			order by count(����) desc) e 
		on c.����N�X=left(e.�������W��,3)
where ���������O=1


 ---------------------------------------------- by ��� view -----------------------------------------------------
-- select * from �������_����ݩ� 
-- select distinct left(�������W��,3) from �������_���������O 
-- 
-- 
-- select left(�������W��,3),count(*),max(���������O) from �������_���������O 
-- group by left(�������W��,3)
alter view v_�������_����ݩ� as 
select a.*,
	case when b.���O is NULL then 0
		else b.���������O end as ���������O,
	 case when a.AUM������A�O='E' then 'a.�Ѳ���'
		  when a.AUM������A�O='B' then 'b.�Ũ髬'
		  when a.AUM������A�O='M' then 'c.�f����'
		  when a.AUM������A�O='W' then 'd.���ū�'
		  when a.AUM������A�O='F' then 'e.�զX��'
		  when a.AUM������A�O='FT' then 'f.���f��'
		  when a.AUM������A�O='I' then 'g.���ƫ�'
		  when a.AUM������A�O='O' then 'h.��L��' else 'ND' end as ��ꫬ�A�O,
	c.cluster 
from �������_����ݩ� a
	left join �������_���������O b 
		on a.����N�X= b.����N�X
	left join �������_������s c 
		on c.����N�X= a.����N�X

-- where ���������O =1

----------- �������P�N�X ---
-- select ����N�X + '_'+�������W�� [����W��] 
-- into �������_�������W��
-- from db_wm.dbo.v_fund 

--------------------------------------------------------- �����ݩ�Table���� ------------------------------------------------------------------------------------------------------
-- cluster1 : �ꤺ�Ѳ��� (546)
select * from v_�������_����ݩ�
	where cluster = 1

-- cluster2 : ��~�Ũ髬 (1031)
select * from v_�������_����ݩ�
	where cluster = 2

-- cluster2 : ��~�Ѳ��� (1200)
select * from v_�������_����ݩ�
	where cluster = 3


---- ���ʰ���S�x --
select b.cluster,a.�����Ҧr��,�������W�� from v_�������_���ʩ���  a
	left join v_�������_����ݩ� b on left(a.�������W��,3) = b.����N�X
where [���ʵn���~] >= 2015

---------------------------------------------------------���(����)���˲M�� ------------------------------------------------------------------------------------------------------
---�����槹R code (�������_Hybrid.r) ---
-- 
select top 10 * from �������_�������W��
select * from dbo.�������_���~�V�X��_���M�� a

select  a.id [�����Ҧr��],
	b.����W�� [���1] ,
	c.����W�� [���2],
	d.����W�� [���3],
	e.����W�� [���4],
	f.����W�� [���5]
into dbo.�������_���~�V�X��_���M��1 
from dbo.�������_���~�V�X��_���M�� a
	left join �������_�������W�� b on left(b.����W��,3)=���1 
	left join �������_�������W�� c on left(c.����W��,3)=���2 
	left join �������_�������W�� d on left(d.����W��,3)=���3 
	left join �������_�������W�� e on left(e.����W��,3)=���4 
	left join �������_�������W�� f on left(f.����W��,3)=���5 
--���˰����
select top 20 ���1,count(*) n 
into #recc_counts
from �������_���~�V�X��_���M��1 
group by ���1
order by 2 desc

drop table #hot_counts
--������
select top 100 �������W��,count(����) n
into #hot_counts
from �������_���ʩ���_2015
group by �������W��
order by count(����) desc
--- 
select a.���1 [���˰��1],
	a.n [���˦���],
	b.�������W�� [������],
	b.n [�q2015�_���Ҽ�]
 from #recc_counts a
	left join #hot_counts  b on left(b.�������W��,3) = left(a.���1,3)

select top 10 * from project2017.dbo.�������_���~�V�X��_���M��1
---------------------------------------------------------- ���հ� -------------------------------------------------------------------------------------------------------------- 

--group by cluster 

select 
	count(*) �����,
	sum(�ꤺ�~������O) ��~�����,
	avg(������ߴX�~) �������ߴX�~,
	sum(���������O) ��������,
	 sum(�����q�ŵ��O) �����q�ż�, 
	avg(Sharpe) ����Sharpe,
	avg(Beta) ����Beta,
	avg([�@�Ӥ�ֿn���S�v(%)]) [�����@�Ӥ�ֿn���S�v(%)],
	avg([�T�Ӥ�ֿn���S�v(%)]) [�����T�Ӥ�ֿn���S�v(%)],
	avg([���Ӥ�ֿn���S�v(%)]) [�������Ӥ�ֿn���S�v(%)],
	avg([�@�~�ֿn���S�v(%)]) [�����@�~�ֿn���S�v(%)]
	 from v_�������_����ݩ�
group by �ꤺ�~������O --cluster


select top 10 �O����������O,*from v_�������_����ݩ�



select * from v_�������_������ʰ��
select top 10 * from v_�������_�������
select top 10 �ϰ�O,* from db_wm.dbo.v_fund
select top 10 * from �������_���������O
select top 10 * from �������_����ݩ�
select top 10 * from v_�������_������� where �ϰ�O= 'LU'
select * from v_�������_������ʰ��
select  
--avg([���~�ֿn���S�v(%)]) 
from  project2017.dbo.�������_����ݩ� where [���~�ֿn���S�v(%)] is not null

select count(*) n ,�����Ҧr��,�������W�� 
into #temp
from v_�������_���ʩ��� 
where [���ʵn���~] >= 2015
group by �����Ҧr��,�������W��

select top 10 * from #temp
order by n desc
-- select top 100 convert(varchar(4),YYYYMMDD,112) yyymm,*
-- from �������_���ʩ��� where ���Ұ���O= 'Y38'
