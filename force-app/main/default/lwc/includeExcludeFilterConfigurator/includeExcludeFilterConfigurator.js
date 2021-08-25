/**
 * UI plugin that helps the user configure the Include Exclude Valence Filter.
 */

import ValenceUIConfigurator from 'c/valenceUIConfigurator';

export default class IncludeExcludeFilterConfigurator extends ValenceUIConfigurator {

	conditionOptions = [{label : 'MUST', value : 'MUST'}, {label : 'MUST NOT', value : 'MUST NOT'}];

	// -------------------------------------------
	// ----- User Manipulating Configuration -----
	// -------------------------------------------

	addValue() {
		this.configuration.values.push('');
		this.configUpdated(); // propagate our configuration changes
	}

	removeValue(event) {
		this.configuration.values.splice(event.target.value, 1);
		this.configUpdated(); // propagate our configuration changes
	}

	longDebounceValueUpdated(event) {
		// we debounce so that the user isn't forced to click out of the field before they click save changes, but we use a long debounce so the field doesn't lose focus on re-render
		const index = event.target.dataset.index, value = event.target.value;
		this.debounce(() => {
			this.configuration.values[index] = value;
			this.configUpdated(); // propagate our configuration changes
			}, 2000
		);
	}

	valueUpdatedImmediately(event) {
		clearTimeout(this._debounceTimer); // cancel any pending debounce
		this.configuration.values[event.target.dataset.index] = event.target.value;
		this.configUpdated(); // propagate our configuration changes
	}

	// -----------------------------------------
	// ----- Required Configurator Methods -----
	// -----------------------------------------

	getDefaultShape() {
		return {condition : 'MUST', values : [], ignoreReason : ''};
	}

	computeValid() {
		// valid if we have a condition, an ignore reason, and at least one value
		return Boolean(this.configuration.condition) && this.configuration.values.length > 0 && Boolean(this.configuration.ignoreReason);
	}
}