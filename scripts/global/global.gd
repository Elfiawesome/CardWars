extends Node

var _instance_num := -1
var _instance_socket: TCPServer
var username:String = "N/A"
func _init() -> void:
	if OS.is_debug_build():
		_instance_socket = TCPServer.new()
		for n in range(0,4):
			if _instance_socket.listen(5000 + n) == OK:
				_instance_num = n
				break
		
		assert(_instance_num >= 0, "Unable to determine instance number. Seems like all TCP ports are in use")
	
	if _instance_num == 0:
		username = "Elfiawesome23"
	else:
		username = unexpected_names[randi_range(1,unexpected_names.size()-1)] + str(randi_range(1,100))
		


var unexpected_names:Array[String] = [
	"aidbelfalas",
	"dealergaladrim",
	"evaluationbrandywine",
	"frequentlydori",
	"shallshadowfax",
	"fiftygwaihir",
	"morningnazgul",
	"switcholiphaunt",
	"burdenemnet",
	"scriptpalantir",
	"respondbrandybuck",
	"eastarwen",
	"widespreadproudfoot",
	"keptrivendell",
	"lawnluthien",
	"beanringbearer",
	"furnitureradagast",
	"whyosgiliath",
	"landerebor",
	"ladyanduin",
	"noisetroll",
	"behaviorminhiriath",
	"cellmountains",
	"horizonaglarond",
	"triangleerkenbrand",
	"effectgorgoroth",
	"fantasyguldur",
	"schooldain",
	"privacyettenmoors",
	"roughlygaladriel",
	"somethingharadwaith",
	"disabilityeomer",
	"civilianhavens",
	"shootingorthanc",
	"moleculesancho",
	"medicationharadrim",
	"prosecutorbregalad",
	"dugangmar",
	"moreovertook",
	"porchcirith",
	"adjustmentmathom",
	"inchsaruman",
	"carbonorc",
	"presencehollin",
	"marginori",
	"screenbaranduin",
	"installlorien",
	"lungstormcrow",
	"declinearnor",
	"chamberoin",
	"hardbeorn",
	"rolepipeweed",
	"weighthuorn",
	"pickmallorn",
	"heeltheoden",
	"manentwade",
	"conditionmearas",
	"sinkmorgoth",
	"slobenedwaith",
	"versionhobbiton",
	"facilitydagorlad",
	"viatrolls",
	"armedthranduil",
	"markbombur",
	"deviceazog",
	"provisionbagginses",
	"numeralmindolluin",
	"conceptloudwater",
	"quicklyeregion",
	"sufficienthoarwell",
	"governorlebennin",
	"wroteeowyn",
	"upperfeanor",
	"surfacedwarves",
	"accompanyurukhai",
	"loudboromir",
	"amendsmaug",
	"shortlytirith",
	"dangerslinker",
	"failuremirkwood",
	"grainnori",
	"committhorin",
	"pilebeorning",
	"woundcaradhras",
	"caughtungol",
	"boyelfstone",
	"exhibithobbit",
	"untilmithril",
	"testimonyathelas",
	"lostgamgee",
	"mountwormtongue",
	"visualglanduin",
	"stomachelessar",
	"eventlegolas",
	"mouthbarliman",
	"speciesriddermark",
	"crisiswaybread",
	"charityvalinor",
	"againstrhun",
	"taplembas",
	"duepippin",
	"arrivalorodruin",
	"laborithil",
	"yeahbofur",
	"mathgondor",
	"conferencefornost",
	"youthgandalf",
	"boughtcelebrant",
	"identitycarc",
	"eventuallyentwash",
	"merelytamarisk",
	"travelmidgewater",
	"noonperegrin",
	"inquirymorannon",
	"sectorrohirrim",
	"principalbutterbur",
	"thousandgollum",
	"mythbifur",
	"basicallylothlorien",
	"jokemordor",
	"optionhalfling",
	"feelingwarg",
	"halferiador",
	"ensureent",
	"insightquickbeam",
	"painthingol",
	"displayevendim",
	"howdenethor",
	"generallyimladris",
	"approvalbilbo",
	"limitationfaramir",
	"someonenimrais",
	"internetfangorn",
	"learningesgaroth",
	"bulletdunedain",
	"extremesauron",
	"apparentsackville",
	"occupationelanor",
	"themtreebeard",
	"decadedwalin",
	"rollmorgul",
	"callaragorn",
	"willshelob",
	"strategicdunland",
	"exceptionrohan",
	"carrierroac",
	"partybalin",
	"democracybombadil",
	"addressdurin",
	"pagekili",
	"dinnerbree",
	"pricewitchking",
	"distributeglorfindel",
	"payringwraith",
	"nowheresamwise",
	"combineelrond",
	"assaultmoria",
	"grantgloin",
	"taleweathertop",
	"ingredientgrima",
	"sequencemeriadoc",
	"creditbolg",
	"embracekhazad",
	"teenagersmeagol",
	"womenelven",
	"himselfdryad",
	"wasbalrog",
	"toeevenstar",
	"clearlypelennor",
	"meanwhilefili",
	"sleepshire",
	"initialeorlingas",
	"linkmithrandir",
]
