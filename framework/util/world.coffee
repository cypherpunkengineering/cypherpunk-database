# copyright 2015 J. Maurice <j@wiz.biz>

require '..'

wiz.package 'wiz.framework.util.world'

class wiz.framework.util.world.regions
	@NA: 'North America'
	@SA: 'Central & South America'
	@CR: 'Caribbean'
	@OP: 'Oceania & Pacific'
	@EU: 'Europe'
	@ME: 'Middle East'
	@AF: 'Africa'
	@AS: 'Asia & India Subcontinent'

wiz.framework.util.world.regionOrder = [
	'NA'
	'SA'
	'CR'
	'EU'
	'ME'
	'AF'
	'AS'
	'OP'
]

class wiz.framework.util.world.regionMap
	@NA: [ #{{{
		'US'
		'CA'
		'MX'
	] #}}}
	@SA: [ #{{{
		'AR'
		'BR'
		'CL'
		'CO'
		'CR'
		'EC'
		'GT'
		'PA'
		'PE'
		'UY'
		'VE'
		'BZ'
		'BO'
		'SV'
		'GF'
		'GY'
		'HN'
		'NI'
		'PY'
		'SR'
	] #}}}
	@CR: [ #{{{
		'AW'
		'BS'
		'BB'
		'BM'
		'DO'
		'HT'
		'JM'
		'PR'
		'TT'
		'VI'
		'AI'
		'AG'
		'BQ'
		'VG'
		'KY'
		'CW'
		'DM'
		'GD'
		'GP'
		'MQ'
		'MS'
		'MF'
		'SX'
		'KN'
		'LC'
		'VC'
		'TC'
	] #}}}
	@OP: [ #{{{
		'AS'
		'AU'
		'FJ'
		'GU'
		'NZ'
		'MP'
		'VU'
		'WF'
		'CK'
		'PF'
		'MH'
		'FM'
		'NC'
		'PW'
		'PG'
	] #}}}
	@EU: [ #{{{
		'BE'
		'FR'
		'DE'
		'IT'
		'ES'
		'CH'
		'NL'
		'TR'
		'GB'
		'AL'
		'AM'
		'AT'
		'AZ'
		'BY'
		'BA'
		'BG'
		'HR'
		'CY'
		'CZ'
		'DK'
		'EE'
		'FO'
		'FI'
		'GE'
		'GI'
		'GR'
		'GL'
		'HU'
		'IS'
		'IE'
		'KZ'
		'LV'
		'LI'
		'LT'
		'LU'
		'MK'
		'MT'
		'MD'
		'MC'
		'ME'
		'NO'
		'PL'
		'PT'
		'RO'
		'RU'
		'SM'
		'RS'
		'SK'
		'SI'
		'SE'
		'TM'
		'UA'
		'UZ'
		'VA'
	] #}}}
	@ME: [ #{{{
		'BH'
		'KW'
		'OM'
		'QA'
		'SA'
		'AE'
		'EG'
		'IR'
		'IQ'
		'IL'
		'JO'
		'LB'
		'SY'
		'YE'
	] #}}}
	@AF: [ #{{{
		'BW'
		'EG'
		'KE'
		'MW'
		'MA'
		'MZ'
		'NA'
		'NG'
		'ZA'
		'SZ'
		'ZM'
		'DZ'
		'AO'
		'BJ'
		'BF'
		'BI'
		'CM'
		'CV'
		'CF'
		'TD'
		'CG'
		'CD'
		'DJ'
		'GQ'
		'ER'
		'ET'
		'GA'
		'GM'
		'GH'
		'GN'
		'GW'
		'CI'
		'LS'
		'LR'
		'LY'
		'MG'
		'ML'
		'MR'
		'MU'
		'NE'
		'RE'
		'RW'
		'SN'
		'SC'
		'SL'
		'SO'
		'SD'
		'TZ'
		'TG'
		'TN'
		'UG'
		'ZW'
	] #}}}
	@AS: [ #{{{
		'CN'
		'HK'
		'IN'
		'ID'
		'JP'
		'MY'
		'PH'
		'SG'
		'KR'
		'TW'
		'TH'
		'AF'
		'BD'
		'BT'
		'BN'
		'KH'
		'KG'
		'LA'
		'MO'
		'MV'
		'MN'
		'NP'
		'PK'
		'LK'
		'VN'
	] #}}}

class wiz.framework.util.world.countries

	@NA: #{{{
		US: 'United States'
		CA: 'Canada'
		MX: 'Mexico'
	#}}}
	@SA: #{{{
		AR: 'Argentina'
		BR: 'Brazil'
		CL: 'Chile'
		CO: 'Colombia'
		CR: 'Costa Rica'
		EC: 'Ecuador'
		GT: 'Guatemala'
		PA: 'Panama'
		PE: 'Peru'
		UY: 'Uruguay'
		VE: 'Venezuela, Bolivarian Republic of'
		BZ: 'Belize'
		BO: 'Bolivia, Plurinational State of'
		SV: 'El Salvador'
		GF: 'French Guiana'
		GY: 'Guyana'
		HN: 'Honduras'
		NI: 'Nicaragua'
		PY: 'Paraguay'
		SR: 'Suriname'
	#}}}
	@CR: #{{{
		AW: 'Aruba'
		BS: 'Bahamas'
		BB: 'Barbados'
		BM: 'Bermuda'
		DO: 'Dominican Republic'
		HT: 'Haiti'
		JM: 'Jamaica'
		PR: 'Puerto Rico'
		TT: 'Trinidad and Tobago'
		VI: 'Virgin Islands, U.S.'
		AI: 'Anguilla'
		AG: 'Antigua and Barbuda'
		BQ: 'Bonaire, Sint Eustatius and Saba'
		VG: 'Virgin Islands, British'
		KY: 'Cayman Islands'
		CW: 'Curaçao'
		DM: 'Dominica'
		GD: 'Grenada'
		GP: 'Guadeloupe'
		MQ: 'Martinique'
		MS: 'Montserrat'
		MF: 'Saint Martin (French part)'
		SX: 'Sint Maarten (Dutch part)'
		KN: 'Saint Kitts and Nevis'
		LC: 'Saint Lucia'
		VC: 'Saint Vincent and the Grenadines'
		TC: 'Turks and Caicos Islands'
	#}}}
	@OP: #{{{
		AS: 'American Samoa'
		AU: 'Australia'
		FJ: 'Fiji'
		GU: 'Guam'
		NZ: 'New Zealand'
		MP: 'Northern Mariana Islands'
		VU: 'Vanuatu'
		WF: 'Wallis and Futuna'
		CK: 'Cook Islands'
		PF: 'French Polynesia'
		MH: 'Marshall Islands'
		FM: 'Micronesia, Federated States of'
		NC: 'New Caledonia'
		PW: 'Palau'
		PG: 'Papua New Guinea'
	#}}}
	@EU: #{{{
		BE: 'Belgium'
		FR: 'France'
		DE: 'Germany'
		IT: 'Italy'
		ES: 'Spain'
		CH: 'Switzerland'
		NL: 'Netherlands'
		TR: 'Turkey'
		GB: 'United Kingdom'
		AL: 'Albania'
		AM: 'Armenia'
		AT: 'Austria'
		AZ: 'Azerbaijan'
		BY: 'Belarus'
		BA: 'Bosnia and Herzegovina'
		BG: 'Bulgaria'
		HR: 'Croatia'
		CY: 'Cyprus'
		CZ: 'Czech Republic'
		DK: 'Denmark'
		EE: 'Estonia'
		FO: 'Faroe Islands'
		FI: 'Finland'
		GE: 'Georgia'
		GI: 'Gibraltar'
		GR: 'Greece'
		GL: 'Greenland'
		HU: 'Hungary'
		IS: 'Iceland'
		IE: 'Ireland'
		KZ: 'Kazakhstan'
		LV: 'Latvia'
		LI: 'Liechtenstein'
		LT: 'Lithuania'
		LU: 'Luxembourg'
		MK: 'Macedonia, the former Yugoslav Republic of'
		MT: 'Malta'
		MD: 'Moldova, Republic of'
		MC: 'Monaco'
		ME: 'Montenegro'
		NO: 'Norway'
		PL: 'Poland'
		PT: 'Portugal'
		RO: 'Romania'
		RU: 'Russian Federation'
		SM: 'San Marino'
		RS: 'Serbia'
		SK: 'Slovakia'
		SI: 'Slovenia'
		SE: 'Sweden'
		TM: 'Turkmenistan'
		UA: 'Ukraine'
		UZ: 'Uzbekistan'
		VA: 'Holy See (Vatican City State)'
	#}}}
	@ME: #{{{
		BH: 'Bahrain'
		KW: 'Kuwait'
		OM: 'Oman'
		QA: 'Qatar'
		SA: 'Saudi Arabia'
		AE: 'United Arab Emirates'
		EG: 'Egypt'
		IR: 'Iran, Islamic Republic of'
		IQ: 'Iraq'
		IL: 'Israel'
		JO: 'Jordan'
		LB: 'Lebanon'
		SY: 'Syrian Arab Republic'
		YE: 'Yemen'
	#}}}
	@AF: #{{{
		BW: 'Botswana'
		EG: 'Egypt'
		KE: 'Kenya'
		MW: 'Malawi'
		MA: 'Morocco'
		MZ: 'Mozambique'
		NA: 'Namibia'
		NG: 'Nigeria'
		ZA: 'South Africa'
		SZ: 'Swaziland'
		ZM: 'Zambia'
		DZ: 'Algeria'
		AO: 'Angola'
		BJ: 'Benin'
		BF: 'Burkina Faso'
		BI: 'Burundi'
		CM: 'Cameroon'
		CV: 'Cape Verde'
		CF: 'Central African Republic'
		TD: 'Chad'
		CG: 'Congo'
		CD: 'Congo, the Democratic Republic of the'
		DJ: 'Djibouti'
		GQ: 'Equatorial Guinea'
		ER: 'Eritrea'
		ET: 'Ethiopia'
		GA: 'Gabon'
		GM: 'Gambia'
		GH: 'Ghana'
		GN: 'Guinea'
		GW: 'Guinea-Bissau'
		CI: 'Côte d\'Ivoire'
		LS: 'Lesotho'
		LR: 'Liberia'
		LY: 'Libya'
		MG: 'Madagascar'
		ML: 'Mali'
		MR: 'Mauritania'
		MU: 'Mauritius'
		NE: 'Niger'
		RE: 'Réunion'
		RW: 'Rwanda'
		SN: 'Senegal'
		SC: 'Seychelles'
		SL: 'Sierra Leone'
		SO: 'Somalia'
		SD: 'Sudan'
		TZ: 'Tanzania, United Republic of'
		TG: 'Togo'
		TN: 'Tunisia'
		UG: 'Uganda'
		ZW: 'Zimbabwe'
	#}}}
	@AS: #{{{
		CN: 'China'
		HK: 'Hong Kong'
		IN: 'India'
		ID: 'Indonesia'
		JP: 'Japan'
		MY: 'Malaysia'
		PH: 'Philippines'
		SG: 'Singapore'
		KR: 'Korea, Republic of'
		TW: 'Taiwan, Province of China'
		TH: 'Thailand'
		AF: 'Afghanistan'
		BD: 'Bangladesh'
		BT: 'Bhutan'
		BN: 'Brunei Darussalam'
		KH: 'Cambodia'
		KG: 'Kyrgyzstan'
		LA: 'Lao People\'s Democratic Republic'
		MO: 'Macao'
		MV: 'Maldives'
		MN: 'Mongolia'
		NP: 'Nepal'
		PK: 'Pakistan'
		LK: 'Sri Lanka'
		VN: 'Viet Nam'
	#}}}

class wiz.framework.util.world.countryPricingTier
#{{{
	@CH: 1
	@LU: 1
	@ZM: 1
	@JE: 1
	@BM: 1
	@NO: 1
	@MC: 1
	@QA: 1
	@GI: 1
	@AU: 1
	@KY: 1
	@DK: 1
	@US: 1
	@VG: 1
	@SE: 1
	@AE: 1
	@BS: 1
	@IE: 1
	@UK: 1
	@NL: 1
	@FI: 1
	@GE: 1
	@AW: 1
	@JP: 1
	@CA: 1
	@FR: 1
	@SG: 1
	@GU: 1
	@GL: 1
	@AD: 1
	@NZ: 1
	@AO: 1
	@BE: 1
	@HK: 1
	@GG: 1
	@FO: 1
	@AT: 1
	@NC: 1
	@KW: 1
	@BN: 1
	@IS: 1
	@KR: 1
	@IT: 1
	@OM: 1
	@RE: 1
	@IL: 1
	@SA: 1
	@GA: 1
	@PR: 1
	@ES: 1
	@BB: 1
	@CY: 1
	@MT: 1
	@PF: 1
	@BZ: 1
	@ZA: 1
	@MU: 1
	@TW: 1
	@SI: 1
	@GD: 1
	@BH: 1
	@CW: 1
	@MW: 1
	@GQ: 1
	@PT: 1
	@JM: 1
	@CZ: 1
	@AR: 1
	@LS: 1
	@MY: 1
	@GR: 1
	@CL: 1
	@SK: 1
	@LB: 1
	@EE: 1
	@PL: 1
	@HR: 1
	@UY: 1
	@IM: 1
	@SR: 1
	@SZ: 1
	@CR: 1
	@PA: 1
	@BR: 1
	@MZ: 1
	@TR: 1
	@NG: 1
	@CN: 1
	@MX: 1
	@TT: 1
	@LV: 1
	@HT: 1
	@FJ: 1
	@LT: 1
	@RU: 1
	@HU: 1
	@SD: 1
	@LY: 2
	@JO: 2
	@NA: 2
	@TZ: 2
	@MV: 2
	@KZ: 2
	@NI: 2
	@ME: 2
	@IQ: 2
	@GT: 2
	@VE: 2
	@BO: 2
	@BA: 2
	@MG: 2
	@BW: 2
	@AZ: 2
	@HN: 2
	@DM: 2
	@RS: 2
	@BG: 2
	@TH: 2
	@BY: 2
	@ZW: 2
	@PE: 2
	@DO: 2
	@RO: 2
	@KE: 2
	@CO: 2
	@CM: 2
	@MN: 2
	@RW: 2
	@IN: 2
	@IR: 2
	@AL: 2
	@PY: 2
	@LC: 2
	@MA: 2
	@ML: 2
	@TN: 2
	@MK: 2
	@UG: 2
	@TM: 2
	@SV: 2
	@UZ: 2
	@EC: 2
	@UA: 2
	@LK: 2
	@CD: 2
	@GH: 2
	@SO: 2
	@KG: 2
	@DZ: 3
	@BD: 3
	@VN: 3
	@PH: 3
	@AM: 3
	@ID: 3
	@GE: 3
	@BU: 3
	@LA: 3
	@PG: 3
	@SC: 3
	@EG: 3
	@BI: 3
	@SY: 3
	@ET: 3
	@MD: 3
	@KH: 3
	@PK: 3
	@YE: 3
	@AF: 3
	@GY: 3
	@SN: 3
	@CV: 3
	@TJ: 3
	@NP: 3
	@WS: 3
	@GM: 3
	@CU: 3
#}}}

# vim: foldmethod=marker wrap
