/**
 * Allows you to only accept records with certain values and/or exclude records with certain values.
 */
global with sharing class IncludeExcludeFilter implements valence.SchemaAwareTransformationFilter, valence.ConfigurablePerMappingFilter {

	// ----------------------------------------
	// ----- ConfigurablePerMappingFilter -----
	// ----------------------------------------

	public String getMappingConfigurationLightningComponent() {
		return 'c:includeExcludeFilterConfigurator';
	}

	public String getMappingConfigurationStructure() {
		return null;
	}

	public String explainMappingConfiguration(String configStr) {

		try {
			Configuration config = (Configuration)JSON.deserialize(configStr, Configuration.class);
			String explanation = '<p>In order to not be ignored, values in this field {0} be one of these:</p><ul>{1}</ul>';

			String values = '';
			for(String value : config.values) {
				values += '<li>' + value + '</li>';
			}
			return String.format(explanation, new List<String>{config.condition, values});
		}
		catch(Exception e) {
			return '<p class="slds-theme_error">This configuration is malformed.</p>';
		}
	}

	// --------------------------------
	// ----- TransformationFilter -----
	// --------------------------------

	public Boolean validFor(valence.LinkContext context) {
		return true;
	}

	public void process(valence.LinkContext context, List<valence.RecordInFlight> records) {

		Map<valence.FieldPath, Configuration> configsBySourcePath = new Map<valence.FieldPath, Configuration>();

		/*
		 * Assemble any configs that have been set up by admins.
		 */
		for(valence.Mapping mapping : context.mappings.values()) {

			// skip blank configurations
			if(String.isNotBlank(mapping.configuration)) {
				try {
					Configuration config = (Configuration)JSON.deserialize(mapping.configuration, Configuration.class);
					configsBySourcePath.put(mapping.sourcePath, config);
				}
				catch(Exception e) {
					throw new valence.FilterException('Cannot parse IncludeExcludeFilter configuration: ' + mapping.configuration, e);
				}
			}
		}

		// bail out if we didn't find any
		if(configsBySourcePath.isEmpty()) {
			return;
		}

		/*
		 * Iterate through our records, ignoring where appropriate.
		 */
		for(valence.RecordInFlight record : records) {
			for(valence.FieldPath sourcePath : configsBySourcePath.keySet()) {
				Configuration config = configsBySourcePath.get(sourcePath);
				String value = String.valueOf(record.getOriginalProperty(sourcePath));
				if(value != null) {
					if('MUST'.equalsIgnoreCase(config.condition)) {
						if(!config.values.contains(value)) {
							record.ignore(config.ignoreReason);
						}
					}
					else if('MUST NOT'.equalsIgnoreCase(config.condition)) {
						if(config.values.contains(value)) {
							record.ignore(config.ignoreReason);
						}
					}
				}
			}
		}
	}

	// -------------------------------------------
	// ----- SchemaAwareTransformationFilter -----
	// -------------------------------------------

	public valence.FilterSchema describeSchema(valence.LinkContext context) {
		valence.FilterSchema schema = new valence.FilterSchema();

		for(valence.Mapping mapping : context.mappings.values()) {

			// skip blank configurations
			if(String.isNotBlank(mapping.configuration)) {
				schema.addTouch(valence.FilterSchema.buildSourceTouch('EVALUATES').onField(mapping));
			}
		}
		return schema;
	}

	/**
	 * Simple class for holding the configuration needed for this filter.
	 */
	private class Configuration {

		private String condition;
		private Set<String> values;
		private String ignoreReason;
	}
}