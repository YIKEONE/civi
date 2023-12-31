-- ChoosableGoodyHuts_Icons
-- Author: Konomi
-- DateCreated: 7/29/2023 1:31:49
--------------------------------------------------------------

INSERT INTO IconTextureAtlases
		(Name,									IconSize,		Filename)
VALUES	('ICON_ATLAS_NOTIFICATION_KNM_CGH',		40,				'ChoosableGoodyHuts40.dds'),
		('ICON_ATLAS_NOTIFICATION_KNM_CGH',		100,			'ChoosableGoodyHuts100.dds');

INSERT INTO IconDefinitions
		(Name,											Atlas,									'Index')
VALUES	('ICON_NOTIFICATION_KNM_CHOOSE_GOODYHUT',		'ICON_ATLAS_NOTIFICATION_KNM_CGH',		0);
