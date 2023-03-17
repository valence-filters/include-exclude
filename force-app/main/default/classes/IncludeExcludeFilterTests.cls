/**
 * Exercises the IncludeExcludeFilter class.
 */
@IsTest
private class IncludeExcludeFilterTests {

	@IsTest static void testMust() {

		// setup up an artificial Context to use for our test
		valence.LinkContext context = new valence.LinkContext();
		context.linkSourceName = 'Alpha';
		context.mappings = new Map<String, valence.Mapping>{
			'firstMapping' => valence.ValenceTestUtil.createTestMapping('firstMapping', 'Employer', 'Company', null),
			'secondMapping' => valence.ValenceTestUtil.createTestMapping('secondMapping', 'PersonName', 'LastName', null),
			'thirdMapping' => valence.ValenceTestUtil.createTestMapping('thirdMapping', 'Industry', 'Sector', '{"condition":"MUST","values":["Explosives","Space Exploration"],"ignoreReason":"This industry is dangerous."}')
		};

		List<valence.RecordInFlight> records = new List<valence.RecordInFlight>{
			new valence.RecordInFlight(new Map<String, Object>{
				'Employer' => '12',
				'PersonName' => 'George',
				'Industry' => 'Agriculture'
			}),
			new valence.RecordInFlight(new Map<String, Object>{
				'Employer' => '10',
				'PersonName' => 'Sally',
				'Industry' => 'Space Exploration'
			})
		};

		Test.startTest();
		new IncludeExcludeFilter().process(context, records);
		Test.stopTest();

		System.assertEquals(2, records.size());
		System.assertEquals(true, records[0].isIgnored());
		System.assertEquals(false, records[1].isIgnored());
	}

	@IsTest static void testMustNot() {

		// setup up an artificial Context to use for our test
		valence.LinkContext context = new valence.LinkContext();
		context.linkSourceName = 'Alpha';
		context.mappings = new Map<String, valence.Mapping>{
			'firstMapping' => valence.ValenceTestUtil.createTestMapping('firstMapping', 'Employer', 'Company', null),
			'secondMapping' => valence.ValenceTestUtil.createTestMapping('secondMapping', 'PersonName', 'LastName', null),
			'thirdMapping' => valence.ValenceTestUtil.createTestMapping('thirdMapping', 'Industry', 'Sector', '{"condition":"MUST NOT","values":["Explosives","Space Exploration"],"ignoreReason":"This industry is dangerous."}')
		};

		List<valence.RecordInFlight> records = new List<valence.RecordInFlight>{
			new valence.RecordInFlight(new Map<String, Object>{
				'Employer' => '12',
				'PersonName' => 'George',
				'Industry' => 'Agriculture'
			}),
			new valence.RecordInFlight(new Map<String, Object>{
				'Employer' => '10',
				'PersonName' => 'Sally',
				'Industry' => 'Space Exploration'
			})
		};

		Test.startTest();
		new IncludeExcludeFilter().process(context, records);
		Test.stopTest();

		System.assertEquals(2, records.size());
		System.assertEquals(false, records[0].isIgnored());
		System.assertEquals(true, records[1].isIgnored());
	}

	@IsTest static void testBadConfig() {

		// setup up an artificial Context to use for our test
		valence.LinkContext context = new valence.LinkContext();
		context.linkSourceName = 'Alpha';
		context.mappings = new Map<String, valence.Mapping>{
			'firstMapping' => valence.ValenceTestUtil.createTestMapping('firstMapping', 'Employer', 'Company', null),
			'secondMapping' => valence.ValenceTestUtil.createTestMapping('secondMapping', 'PersonName', 'LastName', 'busted'),
			'thirdMapping' => valence.ValenceTestUtil.createTestMapping('thirdMapping', 'Industry', 'Sector', null)
		};

		List<valence.RecordInFlight> records = new List<valence.RecordInFlight>{
			new valence.RecordInFlight(new Map<String, Object>{
				'Employer' => '12',
				'PersonName' => 'George',
				'Industry' => 'Agriculture'
			}),
			new valence.RecordInFlight(new Map<String, Object>{
				'Employer' => '10',
				'PersonName' => 'Sally',
				'Industry' => 'Space Exploration'
			})
		};

		try {
			new IncludeExcludeFilter().process(context, records);
			System.assert(false, 'Expected an exception due to the malformed configuration.');
		}catch(Exception e) {
			System.assertEquals('valence.FilterException',e.getTypeName());
			System.assertEquals('Cannot parse IncludeExcludeFilter configuration: busted',e.getMessage());
			System.assertNotEquals(null, e.getCause());
		}
	}

	@IsTest static void testNoConfigs() {

		// setup up an artificial Context to use for our test
		valence.LinkContext context = new valence.LinkContext();
		context.linkSourceName = 'Alpha';
		context.mappings = new Map<String, valence.Mapping>{
			'firstMapping' => valence.ValenceTestUtil.createTestMapping('firstMapping', 'Employer', 'Company', null),
			'secondMapping' => valence.ValenceTestUtil.createTestMapping('secondMapping', 'PersonName', 'LastName', null),
			'thirdMapping' => valence.ValenceTestUtil.createTestMapping('thirdMapping', 'Industry', 'Sector', null)
		};

		List<valence.RecordInFlight> records = new List<valence.RecordInFlight>{
			new valence.RecordInFlight(new Map<String, Object>{
				'Employer' => '12',
				'PersonName' => 'George',
				'Industry' => 'Agriculture'
			}),
			new valence.RecordInFlight(new Map<String, Object>{
				'Employer' => '10',
				'PersonName' => 'Sally',
				'Industry' => 'Space Exploration'
			})
		};

		Test.startTest();
		new IncludeExcludeFilter().process(context, records);
		Test.stopTest();

		System.assertEquals(2, records.size());
		System.assertEquals(false, records[0].isIgnored());
		System.assertEquals(false, records[1].isIgnored());
	}

	@IsTest static void testRestrictions() {

		System.assertEquals(true, new IncludeExcludeFilter().validFor(null));
	}

	@IsTest static void testDescribeSchema() {

		// setup up an artificial Context to use for our test
		valence.LinkContext context = new valence.LinkContext();
		context.linkSourceName = 'Alpha';
		context.mappings = new Map<String, valence.Mapping>{
			'firstMapping' => valence.ValenceTestUtil.createTestMapping('firstMapping', 'Employer', 'Company', null),
			'secondMapping' => valence.ValenceTestUtil.createTestMapping('secondMapping', 'PersonName', 'LastName', null),
			'thirdMapping' => valence.ValenceTestUtil.createTestMapping('thirdMapping', 'Industry', 'Sector', '{"condition":"MUST NOT","values":["Explosives","Space Exploration"],"ignoreReason":"This industry is dangerous."}')
		};

		new IncludeExcludeFilter().describeSchema(context);

		// there's no way atm to evaluate the result
	}

	@IsTest static void testConfigurationMethods() {

		IncludeExcludeFilter filter = new IncludeExcludeFilter();

		System.assertNotEquals(null, filter.getMappingConfigurationLightningComponent());
		System.assertEquals(null, filter.getMappingConfigurationStructure());

		String config = JSON.serialize(new Map<String, Object> {
			'condition' => 'MUST NOT',
			'values' => new Set<String>{'Explosives','Space Exploration'},
			'ignoreReason' => 'This industry is dangerous.'
		});

		System.assertEquals('<p>In order to not be ignored, values in this field MUST NOT be one of these:</p><ul><li>Explosives</li><li>Space Exploration</li></ul>', filter.explainMappingConfiguration(config));

		System.assertEquals('<p class="slds-theme_error">This configuration is malformed.</p>', filter.explainMappingConfiguration('broken'));
	}
}