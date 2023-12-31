-- Harvest Lux and Str Rework by Kunsmendon
-- Author: Kunsmendon
-- DateCreated: 9/9/2020 1:46:22 PM
--------------------------------------------------------------
--先填表，因为原表中也有一些数据，所以统一替换
INSERT OR REPLACE INTO Resource_Harvests (Amount,PrereqTech,ResourceType,YieldType) 
SELECT 25,NULL,Resource_YieldChanges.ResourceType,Resource_YieldChanges.YieldType FROM Resource_YieldChanges;

--这一步填写上面留空的PrereqTech，用Case When进行分类，具体的分类过程不一，我觉得用改良来分资源比较合适
UPDATE Resource_Harvests
SET PrereqTech = CASE 
	--这一行填写所有灌溉奢侈
    WHEN Resource_Harvests.ResourceType IN (SELECT Improvement_ValidResources.ResourceType FROM Improvement_ValidResources WHERE ImprovementType ='IMPROVEMENT_PLANTATION') THEN 'TECH_IRRIGATION'
	--这一行填写用农田改良的，也就是制陶术解锁的
    WHEN Resource_Harvests.ResourceType IN (SELECT Improvement_ValidResources.ResourceType FROM Improvement_ValidResources WHERE ImprovementType ='IMPROVEMENT_FARM') THEN 'TECH_POTTERY'
	--这一行挑选出所有矿产资源，但是我不想让战略资源提前出来，因为没发现就能收获掉，总感觉怪怪的
    WHEN Resource_Harvests.ResourceType IN (SELECT Improvement_ValidResources.ResourceType FROM Improvement_ValidResources WHERE ImprovementType IN ('IMPROVEMENT_MINE','IMPROVEMENT_QUARRY') AND NOT ResourceType IN (SELECT Resources.ResourceType FROM Resources WHERE ResourceClassType ='RESOURCECLASS_STRATEGIC')) THEN 'TECH_MASONRY'
	--这一行是牧场和营地的资源，都写在畜牧里面，其中战略的马也在这里填进去
    WHEN Resource_Harvests.ResourceType IN (SELECT Improvement_ValidResources.ResourceType FROM Improvement_ValidResources WHERE ImprovementType IN('IMPROVEMENT_PASTURE','IMPROVEMENT_CAMP')) THEN 'TECH_ANIMAL_HUSBANDRY'
	--这一行还有一种写法，也利用Improvement=渔船的操作来选择，但我一开始不是这么选择的而已
    WHEN Resource_Harvests.ResourceType IN (SELECT Resources.ResourceType FROM Resources WHERE SeaFrequency > 0) THEN 'TECH_CELESTIAL_NAVIGATION'
    END;

--这一步是将Resources表里面的有关战略资源的PrereqTech抄过来，因为小马已经在填过了，所以这里不会填。不过上面就算是没填，这一步也可以填上
UPDATE Resource_Harvests
SET PrereqTech = (SELECT Resources.PrereqTech FROM Resources WHERE Resource_Harvests.ResourceType = Resources.ResourceType)
WHERE PrereqTech IS NULL;

--整理金币的收获产出以及信仰的产出，要适当提高一点，至于食物的话，收获了基本都是上1个人口，不调也罢
UPDATE Resource_Harvests
SET Amount = 50
WHERE YieldType = 'YIELD_GOLD';

UPDATE Resource_Harvests
SET Amount = 35
WHERE YieldType = 'YIELD_FAITH';

--这是让战略的收获更高一点，因为战略能每回合提供
UPDATE Resource_Harvests
SET Amount = 50
WHERE Resource_Harvests.ResourceType IN (SELECT Resources.ResourceType FROM Resources WHERE ResourceClassType ='RESOURCECLASS_STRATEGIC');

--有些资源，包括战略资源，能提供两种产出，那就统一下降到基础值好了
UPDATE Resource_Harvests
SET Amount = 25
WHERE ResourceType IN (SELECT ResourceType FROM Resource_Harvests GROUP BY ResourceType HAVING COUNT(ResourceType)>1);