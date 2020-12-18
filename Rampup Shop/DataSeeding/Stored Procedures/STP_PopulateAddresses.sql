-- ===================================================================================================================================================
/*
	Table's data:		[Master].[Addresses]
	Short description:	Post-deployment data seeding into the table
	Created on:			2020-12-01
	Modified on:		2020-12-07
	Scripted by:		SOFTSERVE\alevc
	Tools:				Values for fields Country, City, Zip, & StreetAddress generated using https://www.generatedata.com/
*/
-- ===================================================================================================================================================

CREATE PROCEDURE [DataSeeding].[STP_PopulateAddresses]
	@OperationRunId INT = NULL,
	@AffectedRows INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SuccessStatus INT,
		@TargetTable VARCHAR(100) = '[Master].[Addresses]';

	BEGIN TRY
		-- Log the event
		DECLARE @Message VARCHAR(MAX) = 'Populating data into ' + @TargetTable;
		EXEC @SuccessStatus = [Logs].[STP_SetEvent] @OperationRunId = @OperationRunId,
			@CallingProc = @@PROCID,
			@Message = @Message;

		IF @SuccessStatus = 1
			RAISERROR('Event logging has failed. Table %s has not been populated', 12, 25, @TargetTable);

		-- Check if table exists
		IF OBJECT_ID(@TargetTable) IS NULL
			RAISERROR('Table %s cannot be populated, as it does not exist in this DB', 16, 25, @TargetTable);

		-- Populate only an empty table:
		IF NOT EXISTS (SELECT TOP 1 * FROM [Master].[Addresses])
		BEGIN
			INSERT INTO [Master].[Addresses] (Country, City, Zip, StreetAddress) 
			VALUES('Guadeloupe','Albacete','7306','Ap #147-4655 A Street'),('South Georgia and The South Sandwich Islands','Castelbianco','Z9409','8031 Sem, St.'),('El Salvador','Kaluga','990881','Ap #965-193 Quisque Road'),('Kyrgyzstan','Kumbakonam','12144','Ap #907-9132 Risus. St.'),('Bolivia','Santander de Quilichao','9080','Ap #892-5708 Eu St.'),('Saint Barthélemy','Perugia','955842','902-1109 Urna Avenue'),('Marshall Islands','Gatineau','09413','P.O. Box 581, 6993 Sit Rd.'),('Guyana','Ponoka','9935 HK','984-5684 Commodo Street'),('Heard Island and Mcdonald Islands','Romford','248438','P.O. Box 951, 4314 Sem. Street'),('Albania','Gravelbourg','15428','P.O. Box 897, 5068 Duis Avenue'),
				('Nicaragua','Huntsville','59308-33604','9782 Lacinia St.'),('Åland Islands','Geest-GŽrompont-Petit-RosiŽre','10800','7225 Mollis. Av.'),('Korea, South','Puerto Montt','665817','Ap #808-8941 Arcu. Rd.'),('Saint Vincent and The Grenadines','Villanova d''Albenga','Q3J 0UV','517-5949 Sit Rd.'),('Gabon','Ussassai','46679-821','Ap #636-7697 Adipiscing Street'),('Austria','Canterbury','224286','Ap #694-414 Nec, Road'),('Isle of Man','Okara','47062','P.O. Box 135, 9227 Egestas Rd.'),('Rwanda','Kasur','2217','296-5468 Fringilla. Street'),('Heard Island and Mcdonald Islands','Woodstock','82149','P.O. Box 423, 7229 Lorem Av.'),('Martinique','Chiniot','86682','282-3295 Cras St.'),
				('Turkey','Polino','15557','P.O. Box 599, 9585 Nullam Rd.'),('Ethiopia','Appelterre-Eichem','492438','8370 Enim Rd.'),('Netherlands','Manukau','882837','721-2332 Ultrices Ave'),('Monaco','Empoli','8051','Ap #628-5979 Donec Ave'),('Pakistan','Warangal','860282','Ap #528-8996 Vivamus Ave'),('Svalbard and Jan Mayen Islands','Heidenheim','25712','730-3993 Lectus Ave'),('Senegal','Orp-Jauche','66-438','9665 Tristique Rd.'),('Uganda','Abbeville','5270','2787 Nonummy. Avenue'),('Nicaragua','Pointe-du-Lac','18890-325','724-6441 Quisque Ave'),('Guatemala','Victoria','5650','P.O. Box 793, 7676 Massa. Street'),
				('French Southern Territories','Guysborough','01971','8949 Sem Road'),('Côte D''Ivoire (Ivory Coast)','Turnhout','15478-345','384-4548 Primis St.'),('Angola','Iowa City','14183','3538 Libero Avenue'),('Liberia','Chhindwara','YE1 9HE','P.O. Box 801, 3354 Lorem Street'),('Guernsey','Santarém','28437-321','4847 Aliquam Av.'),('Israel','Rosoux-Crenwick','P2O 4AL','Ap #740-8115 Laoreet, Road'),('Nigeria','Steyr','1540','P.O. Box 391, 8512 Fringilla, Street'),('Chile','Floriffoux','96040','P.O. Box 567, 6843 Eu, Ave'),('Latvia','Sierra Gorda','21994','P.O. Box 781, 4899 Neque Road'),('Bangladesh','Hilo','94773','9533 Nec, Road'),
				('Romania','Rebecq','N8R 1L6','P.O. Box 743, 8646 Ultricies St.'),('Nigeria','Port Glasgow','15551','3253 Cursus Rd.'),('Central African Republic','Blue Mountains','50114','P.O. Box 129, 5292 Eget St.'),('Norway','Pomarico','Z6106','P.O. Box 164, 2243 Pharetra, Rd.'),('Netherlands','Valkenburg aan de Geul','9411 OT','P.O. Box 402, 702 Non, Avenue'),('Wallis and Futuna','Rostock','66675','3731 Sed Av.'),('Palau','Kent','Y1L 9V5','Ap #676-4624 Est, St.'),('Maldives','Oosterhout','31404','Ap #200-3231 Elementum Road'),('Saint Helena, Ascension and Tristan da Cunha','San Isidro de El General','59998','843 Lectus, Rd.'),('Antarctica','Raichur','36743','P.O. Box 150, 3624 Faucibus Road'),
				('Guam','East Kilbride','14237','P.O. Box 429, 2185 Turpis Av.'),('Micronesia','Curaco de Vélez','13175','Ap #308-442 Scelerisque Av.'),('Cuba','Ararat','Z7049','2508 Eu, St.'),('Guyana','Selva di Cadore','28593','P.O. Box 320, 3994 Luctus Road'),('Mexico','Vishakhapatnam','794273','3847 Sociis Ave'),('Chile','Sint-Denijs','59477','Ap #211-2795 Et Ave'),('Malawi','Samaniego','30915','Ap #158-2647 Etiam St.'),('Ecuador','Assiniboia','548237','4368 Consequat Avenue'),('Kyrgyzstan','Snellegem','13075','Ap #950-5697 Ligula. Rd.'),('Azerbaijan','Obaix','20431','Ap #411-3230 Sed, St.'),
				('French Polynesia','Lebbeke','41654-90615','P.O. Box 808, 8010 Risus Street'),('Sweden','Hoeilaart','R7T 8T0','P.O. Box 483, 8879 Non, Rd.'),('Benin','Yumbel','1208','Ap #235-9701 Arcu St.'),('Gabon','Kostroma','437229','Ap #515-6917 Convallis Avenue'),('Eritrea','Ronciglione','93668','P.O. Box 859, 141 Tellus Rd.'),('Dominican Republic','Fort Good Hope','076746','5938 Arcu. St.'),('Cook Islands','Illkirch-Graffenstaden','97643','Ap #287-4380 Ultrices Rd.'),('Cook Islands','Gujranwala','159216','P.O. Box 129, 7088 Enim Ave'),('Grenada','Vancouver','697714','Ap #711-3929 Augue Rd.'),('Egypt','Cuddapah','00800','P.O. Box 118, 3964 Euismod Av.'),
				('Mauritius','Borgo Valsugana','3589','789-1878 Lacus. St.'),('Tokelau','Lerwick','8027','854-7787 Nisl St.'),('Lesotho','Velsk','21901','2087 Pede Ave'),('Costa Rica','St. Clears','4890 RA','P.O. Box 909, 6356 Blandit Road'),('Madagascar','Fort Saskatchewan','8546','P.O. Box 472, 4371 Nisi Street'),('Denmark','Sagrada Familia','7415 OZ','Ap #692-430 Eu, Rd.'),('Spain','Wels','429161','P.O. Box 153, 3387 Justo Street'),('Cameroon','Corroy-le-Ch‰teau','077501','328-3019 Vel Av.'),('Turkmenistan','Essex','26723','2364 Eleifend Street'),('American Samoa','Cabrero','2939','1623 Lectus. Ave'),
				('Congo (Brazzaville)','BertrŽe','6060','P.O. Box 152, 7910 Vel, Avenue'),('Kuwait','San Rafael','58526','Ap #746-7324 Non St.'),('Congo (Brazzaville)','Bicinicco','35-875','567-7582 Feugiat Rd.'),('Svalbard and Jan Mayen Islands','Zonhoven','EW7 4PF','Ap #876-4352 Phasellus Avenue'),('Russian Federation','HŽlŽcine','22659','P.O. Box 166, 9171 Ridiculus Avenue'),('Ireland','Cottbus','233572','3927 Nunc Av.'),('Kenya','Dilsen-Stokkem','671009','329 Egestas. St.'),('Lesotho','Aquila d''Arroscia','00823','542-1130 Metus Ave'),('Nepal','Fishguard','7911','980-3318 Nonummy Avenue'),('Gibraltar','Fairbanks','8506','989-4481 Mauris Ave'),
				('Eritrea','Mechelen-aan-de-Maas','631875','8726 Feugiat St.'),('Zambia','Ludwigsburg','364103','P.O. Box 824, 2977 Elit. Ave'),('Argentina','Saint-Pierre','AO9C 9AW','1412 Fames Road'),('Moldova','Valéncia','16186','618 Nulla. Avenue'),('Spain','Wetteren','Z9905','P.O. Box 278, 2747 Lorem St.'),('Sri Lanka','Jhelum','6556','1080 Ligula. St.'),('Bosnia and Herzegovina','Baunatal','647206','P.O. Box 350, 3145 Cras St.'),('Armenia','Saint-Leonard','51206','3791 Natoque Street'),('Guyana','Belsele','73966','658-2668 Non, St.'),('Slovakia','Bornival','7744','321-3726 Donec Ave');
			
			-- Output the number of affected rows
			SET @AffectedRows = @@ROWCOUNT;
		END
		RETURN 0
	END TRY
	BEGIN CATCH
		DECLARE @ErrorNumber INT = ERROR_NUMBER(), 
			@ErrorSeverity INT = ERROR_SEVERITY(), 
			@ErrorState INT = ERROR_STATE(), 
			@ErrorProcedure VARCHAR(255) = ERROR_PROCEDURE(), 
			@ErrorLine INT = ERROR_LINE(), 
			@ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE();
		
		-- Log the error
		EXEC [Logs].[STP_SetError] @OperationRunId, @ErrorNumber, @ErrorSeverity, @ErrorState, @ErrorProcedure, @ErrorLine, @ErrorMessage;
		RETURN 1
	END CATCH
END;