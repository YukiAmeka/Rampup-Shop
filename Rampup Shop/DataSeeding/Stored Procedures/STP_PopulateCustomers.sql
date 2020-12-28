-- ===================================================================================================================================================
/*
	Table's data:		[Master].[Customers]
	Short description:	Post-deployment data seeding into the table
	Created on:			2020-11-30
	Modified on:		2020-12-24
	Scripted by:		SOFTSERVE\alevc
	Tools:				Values for fields FirstName, LastName, Email, & Phone generated using https://www.generatedata.com/
*/
-- ===================================================================================================================================================

CREATE PROCEDURE [DataSeeding].[STP_PopulateCustomers]
	@OperationRunId INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SuccessStatus INT,
		@AffectedRows INT = 0,
		@TargetTable VARCHAR(100) = '[Master].[Customers]';

	BEGIN TRY
		-- Check if table exists
		IF OBJECT_ID(@TargetTable) IS NULL
			RAISERROR('Table %s cannot be populated, as it does not exist in this DB', 16, 25, @TargetTable);

		-- Populate only an empty table:
		IF NOT EXISTS (SELECT TOP 1 * FROM [Master].[Customers])
		BEGIN
			INSERT INTO [Master].[Customers] (FirstName, LastName, Email, Phone) 
			VALUES ('Tate','Morrow','eget@felis.co.uk','076 2374 0338'),('Emma','Warner','nec@eget.ca','(0121) 779 9066'),('Thomas','Arnold','urna.convallis@ipsumprimisin.org','055 8042 8930'),('Liberty','Goodman','nibh@netusetmalesuada.com','0980 675 4460'),('Ryan','Ochoa','montes.nascetur.ridiculus@quislectusNullam.com','0800 1111'),('Gary','Pitts','senectus.et@tempor.co.uk','07624 169863'),('Davis','Booth','ornare.tortor.at@enimSed.org','(01059) 08013'),('Dieter','Mccoy','imperdiet.ullamcorper.Duis@Aliquam.ca','0500 364747'),('Clarke','Bradford','magnis.dis.parturient@Suspendissesed.org','0361 099 2118'),('Lev','Yang','lacus.vestibulum.lorem@semconsequatnec.ca','0874 647 9279'),
				('Jaden','Higgins','commodo.ipsum@aliquet.co.uk','(024) 1991 6532'),('Magee','Mclean','elementum.purus.accumsan@luctus.net','056 0545 9724'),('Tiger','Rodriguez','amet.ultricies.sem@eget.co.uk','055 6034 1099'),('Vance','Baker','nunc.In@Morbi.ca','0349 021 4283'),('Judith','Ochoa','enim@pharetranibhAliquam.net','070 9907 1889'),('Sandra','Moss','eleifend@nullavulputate.net','07088 477731'),('Kay','Leon','eleifend.nec.malesuada@pellentesqueSed.edu','0939 580 2235'),('Lisandra','Dixon','ut.cursus@elit.com','055 4840 0641'),('Yvette','Velazquez','erat@nonvestibulumnec.ca','(0116) 039 8934'),('Emerson','Hampton','Quisque@nuncinterdumfeugiat.co.uk','055 0271 8461'),
				('Lawrence','Shelton','Duis.at.lacus@auctorquis.net','0845 46 40'),('Hayes','Johnson','egestas.Duis@DonecegestasDuis.ca','055 6596 4706'),('Penelope','Hendricks','neque@Namconsequatdolor.org','(01928) 12077'),('Nasim','Stafford','ac.facilisis.facilisis@lacusvariuset.com','07545 891696'),('Palmer','Munoz','Mauris.ut@Etiam.ca','070 9979 1931'),('Flavia','Whitehead','augue.eu@consequatauctor.co.uk','055 8126 0836'),('Lani','Best','diam@dictumcursusNunc.ca','076 3159 9372'),('Anne','Guerrero','malesuada.fringilla.est@vestibulum.com','055 0147 6896'),('Jakeem','Henson','mollis.nec.cursus@ultriciesdignissim.org','070 9191 3293'),('Tamara','Beard','dolor@pedenec.edu','0500 206509'),
				('Xerxes','Watson','scelerisque.mollis.Phasellus@risus.ca','(01835) 99963'),('Edan','Cook','est.vitae.sodales@actellus.co.uk','056 0975 9999'),('Kelly','George','eu.turpis@mattis.co.uk','0800 1111'),('Kalia','Brock','mi.enim@egetvenenatis.edu','(01189) 864902'),('Rashad','Gay','eu@ac.org','0838 403 1000'),('Desiree','Simpson','a.ultricies.adipiscing@fringillamilacinia.net','(01336) 633119'),('Ciaran','Daniels','fringilla@luctus.ca','(0161) 472 4853'),('Cleo','Ayala','mattis.velit@diamdictumsapien.edu','(017953) 05146'),('Keaton','Cotton','et@consequatnec.ca','(01848) 187337'),('Kibo','Gomez','quam@Vestibulumante.ca','(014225) 25474'),
				('Lawrence','Gregory','mi.Duis@loremluctusut.edu','0800 917 7996'),('Fredericka','Silva','dignissim.tempor@viverraDonec.org','(0131) 370 4230'),('Charles','Slater','Fusce.diam@nonsollicitudin.com','056 8319 2152'),('Sawyer','Franks','ipsum.nunc@nisiMaurisnulla.ca','(017275) 56459'),('Fatima','Gordon','erat.neque.non@Quisque.co.uk','(01028) 04039'),('Cameron','Dyer','Lorem@sitametnulla.net','056 4512 3433'),('Valentine','Shaw','tempus.scelerisque.lorem@Duismienim.ca','076 1106 2619'),('Beatrice','Mcknight','arcu.imperdiet.ullamcorper@DonecfringillaDonec.org','0800 502 3358'),('Vivian','Hester','sit.amet.consectetuer@egestaslaciniaSed.edu','07063 475166'),('Dieter','Hyde','Sed.nulla.ante@ipsumdolor.org','076 3148 6246'),
				('Rudyard','Potts','risus.Donec@Aliquamauctorvelit.org','(016977) 5087'),('Rafael','Bruce','Duis.gravida.Praesent@laciniaatiaculis.com','0845 46 43'),('Wing','Boyer','luctus.lobortis.Class@odio.ca','055 4188 8477'),('Ursa','Dotson','dui.in.sodales@dui.edu','(0113) 037 6545'),('Nash','Nieves','Cras.eu@rutrumjusto.edu','0800 1111'),('Lee','Juarez','lorem@erat.com','070 7443 6375'),('Nomlanga','Hardin','pede@liberoMorbiaccumsan.ca','0837 367 5169'),('Micah','Mullen','ante.bibendum@amet.net','(027) 4102 0685'),('Wing','Keller','Cras@necluctus.co.uk','055 6259 7999'),('Carter','George','mollis.Integer@egetmassaSuspendisse.org','0800 364 5021'),
				('Channing','Madden','orci.Ut.sagittis@disparturient.ca','056 1363 8485'),('Nita','Finch','eu.erat.semper@leo.net','0800 156525'),('Caleb','Wells','amet.ornare@fermentumfermentumarcu.net','0800 365 6906'),('Nathaniel','Bradshaw','Aliquam@purusin.edu','07262 898049'),('Priscilla','Ortiz','arcu@infelisNulla.edu','(0111) 400 8203'),('Kennan','Maddox','malesuada@varius.net','0800 968895'),('Benjamin','Terry','ante@magnaSedeu.edu','(0151) 869 2034'),('Jamal','Rowland','faucibus@vitaesodalesat.org','(021) 2546 3221'),('Benjamin','Case','Fusce.mollis@tristiqueac.com','0800 337437'),('Rhonda','Christensen','lacinia.Sed.congue@luctusaliquetodio.net','0500 087757'),
				('Jacqueline','Cruz','Duis.volutpat@Mauris.com','0353 807 4875'),('Maya','Bailey','ac.feugiat.non@eget.net','0867 250 6053'),('Elvis','Harris','elementum@Maurisutquam.ca','(0119) 534 9769'),('Wade','Buckley','ullamcorper@semelit.net','0800 158 5666'),('Harlan','Macias','dolor@Vivamussit.org','076 2584 3781'),('Thor','Crosby','tortor@Duis.ca','(016977) 7437'),('Joshua','Ballard','eget@mollis.org','07590 353933'),('Carissa','Haley','Fusce.diam@sagittisfelis.ca','076 0986 0536'),('Quon','Stevens','parturient.montes.nascetur@hendreritconsectetuercursus.ca','(016977) 1079'),('Denton','Beard','mi@dolor.edu','(0161) 578 0351'),
				('Stone','Russo','netus.et.malesuada@velconvallisin.org','(0141) 665 9723'),('Raya','Melendez','nec.tempus@pulvinararcuet.org','055 8430 8755'),('Jamalia','Ballard','Fusce.dolor@turpisIncondimentum.co.uk','0800 826033'),('Barry','Delacruz','lectus@Fuscealiquetmagna.ca','0337 748 0360'),('Herman','Webb','amet.lorem.semper@nibhAliquamornare.com','(016977) 3151'),('Avram','Boyle','Nulla.eu@Curabiturconsequatlectus.co.uk','(016977) 7401'),('Colton','Wagner','Nunc.sed@etultricesposuere.ca','055 6423 2148'),('Lilah','Mann','turpis.nec@lacinia.org','(026) 0757 5333'),('Sasha','Hudson','placerat.eget@ipsumleoelementum.edu','(021) 9439 1407'),('Gretchen','Valdez','et.magnis@magna.ca','07216 275945'),
				('Riley','Mccoy','Ut@arcuet.com','(01577) 10477'),('Dylan','Pickett','fringilla@Aliquamgravidamauris.net','055 5932 2099'),('Bruno','Mcneil','quis.accumsan@sollicitudin.edu','(021) 9670 9608'),('Britanni','Byrd','accumsan.laoreet@enimsit.org','0863 605 4105'),('Ishmael','Norris','turpis@utaliquam.net','0326 494 3728'),('Stuart','Miles','fames.ac.turpis@dictum.edu','0896 756 7345'),('Kelly','Myers','et.ultrices.posuere@auguescelerisquemollis.net','(016977) 9697'),('Gail','Gray','Praesent@tempusloremfringilla.net','0800 1111'),('Christine','Glenn','risus.quis.diam@nulla.edu','(0117) 486 7240'),('Victoria','Hill','vulputate.risus.a@Integer.net','07009 674715'),
				('Sopoline','Beach','primis.in.faucibus@Nulla.org','07338 185586'),('Caesar','Grant','vestibulum.Mauris.magna@Etiamvestibulum.net','(0151) 899 6419'),('Zelda','Phelps','a.ultricies.adipiscing@vulputateullamcorpermagna.edu','0500 645251'),('Kathleen','Walker','placerat@Donecvitaeerat.edu','0881 295 0998'),('Curran','Conley','purus.Duis.elementum@molestiein.ca','0800 561195'),('Trevor','Stone','arcu.Aliquam@maurisipsumporta.co.uk','0991 841 0311'),('Gillian','Dickson','Nulla.tempor@lectus.ca','0327 769 5612'),('Boris','Hunter','ut.ipsum.ac@Donecporttitor.org','0886 446 1464'),('Velma','Walters','lacinia@sempercursus.com','055 2009 6344'),('Sebastian','Barry','Sed.et.libero@utaliquamiaculis.co.uk','0800 472182'),
				('Venus','Byrd','fringilla@tristique.net','(022) 9276 1989'),('Salvador','Conrad','luctus@vulputatemauris.com','055 5444 2333'),('Alma','Booker','Cum.sociis@placeratvelit.org','0800 231329'),('Hall','Sosa','Sed@AeneanmassaInteger.net','056 0824 4027'),('Ciaran','Kirkland','quam@ante.com','076 5735 9583'),('Carolyn','Ruiz','per.conubia@Crasdolordolor.com','0902 470 8667'),('Martena','Chase','vitae@egestasnuncsed.co.uk','(026) 9821 4590'),('Tamara','Duke','Sed@fermentum.net','076 7293 0906'),('Suki','Gray','enim.Mauris@Donec.ca','0800 527 0597'),('Plato','Atkinson','libero@erategettincidunt.ca','07624 533517'),
				('Kelsie','Oneal','at.sem@Aliquam.edu','(0131) 503 3034'),('Germaine','Mullen','ut.dolor@Sedcongue.co.uk','076 1663 3371'),('Kitra','Hunt','iaculis.odio.Nam@fringillapurus.edu','07624 552875'),('John','Gay','tempor.bibendum@acsemut.com','076 3964 7085'),('Idona','Avery','imperdiet.erat@Morbiquisurna.org','070 3576 8067'),('Camden','Potts','montes.nascetur.ridiculus@et.org','0800 741417'),('Latifah','Reed','erat@pedeCras.ca','070 0455 2726'),('Lydia','Foley','commodo@sociosquad.com','07285 156820'),('Mallory','Saunders','tristique@sedfacilisisvitae.com','070 8732 3658'),('Hakeem','England','lorem.lorem.luctus@rutrumnon.co.uk','0936 557 5095'),
				('Christen','Bright','faucibus@porttitorscelerisqueneque.org','0500 532075'),('Cassidy','Schmidt','Fusce.diam.nunc@Donecluctus.ca','056 2366 9707'),('Judah','Crawford','lorem@Proinnislsem.org','(013125) 41362'),('Mannix','Wolf','placerat.orci.lacus@Proin.net','0800 016299'),('Kuame','Galloway','Mauris.blandit@mollisDuissit.com','0800 1111'),('Lev','Patton','ipsum@dictumProin.net','0500 106529'),('Inez','Faulkner','Donec@arcu.ca','0500 633342'),('Flavia','Stevenson','in@sedhendrerit.com','(016977) 2511'),('Adria','Lott','Curabitur.vel.lectus@magna.com','0374 774 0311'),('Vladimir','Davidson','ligula@accumsanconvallis.net','(01756) 069709'),
				('Theodore','Vaughan','amet.dapibus.id@Naminterdumenim.edu','0800 040 9671'),('Vivian','Mcgowan','quis.turpis.vitae@liberoMorbiaccumsan.org','(01402) 71476'),('Hadley','Edwards','convallis.est.vitae@magnaa.edu','070 2126 2064'),('Reuben','Maldonado','Sed@Duisacarcu.ca','0863 491 8856'),('Avram','Buckner','dictum@ametrisusDonec.edu','0800 046799'),('Brock','Shields','magnis@Cras.org','0360 415 1122'),('Mari','Barr','et.magna.Praesent@sagittis.net','056 5456 3053'),('Devin','Clay','leo.Cras@nec.edu','0845 46 46'),('Kristen','Stein','leo.Cras.vehicula@diamlorem.net','0845 46 42'),('Jameson','Flowers','imperdiet.dictum@Aliquamvulputate.org','(01730) 324887');
			
			-- Output the number of affected rows
			SET @AffectedRows = @@ROWCOUNT;
		END

		-- Log the event
		DECLARE @Message VARCHAR(MAX) = '3) Populating data into ' + @TargetTable;
		EXEC @SuccessStatus = [Logs].[STP_SetEvent] @OperationRunId = @OperationRunId,
			@CallingProc = @@PROCID,
			@AffectedRows = @AffectedRows,
			@Message = @Message;

		IF @SuccessStatus = 1
			RAISERROR('Event logging has failed. Table %s has not been populated', 12, 25, @TargetTable);
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
		
		-- Raiserror to the application
		RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
		
		RETURN 1
	END CATCH
END;