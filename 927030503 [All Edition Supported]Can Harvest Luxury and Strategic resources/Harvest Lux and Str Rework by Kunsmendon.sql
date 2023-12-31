-- Harvest Lux and Str Rework by Kunsmendon
-- Author: Kunsmendon
-- DateCreated: 9/9/2020 1:46:22 PM
--------------------------------------------------------------
--�������Ϊԭ����Ҳ��һЩ���ݣ�����ͳһ�滻
INSERT OR REPLACE INTO Resource_Harvests (Amount,PrereqTech,ResourceType,YieldType) 
SELECT 25,NULL,Resource_YieldChanges.ResourceType,Resource_YieldChanges.YieldType FROM Resource_YieldChanges;

--��һ����д�������յ�PrereqTech����Case When���з��࣬����ķ�����̲�һ���Ҿ����ø���������Դ�ȽϺ���
UPDATE Resource_Harvests
SET PrereqTech = CASE 
	--��һ����д���й���ݳ�
    WHEN Resource_Harvests.ResourceType IN (SELECT Improvement_ValidResources.ResourceType FROM Improvement_ValidResources WHERE ImprovementType ='IMPROVEMENT_PLANTATION') THEN 'TECH_IRRIGATION'
	--��һ����д��ũ������ģ�Ҳ����������������
    WHEN Resource_Harvests.ResourceType IN (SELECT Improvement_ValidResources.ResourceType FROM Improvement_ValidResources WHERE ImprovementType ='IMPROVEMENT_FARM') THEN 'TECH_POTTERY'
	--��һ����ѡ�����п����Դ�������Ҳ�����ս����Դ��ǰ��������Ϊû���־����ջ�����ܸо��ֵֹ�
    WHEN Resource_Harvests.ResourceType IN (SELECT Improvement_ValidResources.ResourceType FROM Improvement_ValidResources WHERE ImprovementType IN ('IMPROVEMENT_MINE','IMPROVEMENT_QUARRY') AND NOT ResourceType IN (SELECT Resources.ResourceType FROM Resources WHERE ResourceClassType ='RESOURCECLASS_STRATEGIC')) THEN 'TECH_MASONRY'
	--��һ����������Ӫ�ص���Դ����д���������棬����ս�Ե���Ҳ���������ȥ
    WHEN Resource_Harvests.ResourceType IN (SELECT Improvement_ValidResources.ResourceType FROM Improvement_ValidResources WHERE ImprovementType IN('IMPROVEMENT_PASTURE','IMPROVEMENT_CAMP')) THEN 'TECH_ANIMAL_HUSBANDRY'
	--��һ�л���һ��д����Ҳ����Improvement=�洬�Ĳ�����ѡ�񣬵���һ��ʼ������ôѡ��Ķ���
    WHEN Resource_Harvests.ResourceType IN (SELECT Resources.ResourceType FROM Resources WHERE SeaFrequency > 0) THEN 'TECH_CELESTIAL_NAVIGATION'
    END;

--��һ���ǽ�Resources��������й�ս����Դ��PrereqTech����������ΪС���Ѿ�������ˣ��������ﲻ����������������û���һ��Ҳ��������
UPDATE Resource_Harvests
SET PrereqTech = (SELECT Resources.PrereqTech FROM Resources WHERE Resource_Harvests.ResourceType = Resources.ResourceType)
WHERE PrereqTech IS NULL;

--�����ҵ��ջ�����Լ������Ĳ�����Ҫ�ʵ����һ�㣬����ʳ��Ļ����ջ��˻���������1���˿ڣ�����Ҳ��
UPDATE Resource_Harvests
SET Amount = 50
WHERE YieldType = 'YIELD_GOLD';

UPDATE Resource_Harvests
SET Amount = 35
WHERE YieldType = 'YIELD_FAITH';

--������ս�Ե��ջ����һ�㣬��Ϊս����ÿ�غ��ṩ
UPDATE Resource_Harvests
SET Amount = 50
WHERE Resource_Harvests.ResourceType IN (SELECT Resources.ResourceType FROM Resources WHERE ResourceClassType ='RESOURCECLASS_STRATEGIC');

--��Щ��Դ������ս����Դ�����ṩ���ֲ������Ǿ�ͳһ�½�������ֵ����
UPDATE Resource_Harvests
SET Amount = 25
WHERE ResourceType IN (SELECT ResourceType FROM Resource_Harvests GROUP BY ResourceType HAVING COUNT(ResourceType)>1);