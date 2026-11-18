extends RefCounted
## String table (simulation toasts and news headlines for adoptions, evolutions, events, bubbles. Owner: simulation module (en), localization (tr/ru)) merged by the I18n autoload; never read directly by game code.
## Format: key -> {"tr": ..., "en": ..., "ru": ...}. Keys are unique across all tables.

const STRINGS := {
	# --- Toasts ---
	"sim.toast.adopted": {"tr": "Politika kabul edildi: {name}", "en": "Policy adopted: {name}", "ru": "Принята политика: {name}"},
	"sim.toast.evolved": {"tr": "Kriz direnç geliştirdi: {name}", "en": "The crisis evolved: {name}", "ru": "Кризис мутировал: {name}"},
	"sim.toast.cured": {"tr": "Direnç kırıldı: {name}", "en": "Resistance cured: {name}", "ru": "Стойкость преодолена: {name}"},
	"sim.toast.immune": {"tr": "Direnç önlendi: kriz artık {name} geliştiremez", "en": "Resistance pre-empted: the crisis can no longer evolve {name}", "ru": "Стойкость предотвращена: кризис больше не разовьет {name}"},
	"sim.toast.adapting": {"tr": "Kriz tek yönlü stratejine ({branch}) uyum sağlıyor. Çeşitlendir!", "en": "The crisis is adapting to your one-sided strategy ({branch}). Diversify!", "ru": "Кризис привыкает к однотипным действиям ({branch}). Чередуйте тактику!"},
	"sim.toast.fleet.dispatched": {"tr": "Acil Müdahale Filosu {to} bölgesine yola çıktı ({eta} ay).", "en": "Emergency Fleet dispatched to {to} (ETA {eta} mo).", "ru": "Экстренный флот отправлен в {to} (прибытие: {eta} мес.)."},
	"sim.toast.fleet.arrived": {"tr": "Acil Müdahale Filosu {to} bölgesine ulaştı! Kirlilik temizleniyor.", "en": "Emergency Fleet arrived in {to}! Rapid relief deployed.", "ru": "Экстренный флот прибыл в {to}! Развёрнута очистка."},
	"sim.news.fleet.arrived": {"tr": "Karargah Acil Filosu {to} sularına demir attı ve kapsamlı kurtarma operasyonu başlattı", "en": "HQ Emergency Fleet reaches {to}, launching rapid pollution containment and coral protection", "ru": "Экстренный флот штаба достиг региона {to} и начал срочную ликвидацию загрязнения"},
	"sim.toast.combo": {"tr": "TAM SEFERBERLİK! {region} 3/3 sinerji kalkanıyla korunuyor (12 ay).", "en": "FULL MOBILIZATION! {region} gains a 3/3 synergy spread shield (12 mo).", "ru": "ПОЛНАЯ МОБИЛИЗАЦИЯ! Регион {region} получил тройной щит (12 мес.)."},
	"sim.news.combo": {"tr": "{region} bölgesinde eşzamanlı temizlik, devriye ve farkındalık tam seferberlik sinerjisi başlattı", "en": "Coordinated cleanup, patrols, and awareness spark Full Mobilization in {region}", "ru": "Скоординированные меры в {region} запустили режим полной мобилизации"},
	"sim.toast.pledge.passed": {"tr": "Zirve taahhüdü tutuldu! (+80 Bütçe, +18 Destek)", "en": "5-year summit pledge fulfilled! (+80 Budget, +18 Support)", "ru": "Обязательство саммита выполнено! (+80 бюджет, +18 поддержка)"},
	"sim.toast.pledge.failed": {"tr": "Önceki 5 yıllık zirve taahhüdü tutulamadı (-15 Destek).", "en": "Previous 5-year summit pledge missed (-15 Support).", "ru": "Предыдущее 5-летнее обязательство не выполнено (-15 поддержка)."},

	# --- News: crisis spreading (variants) ---
	"sim.news.spread.0": {"tr": "{from} bölgesindeki kirlilik akıntısı {to} bölgesine sürüklendi", "en": "Pollution plume from {from} drifts into {to}", "ru": "Шлейф загрязнения из {from} дрейфует в сторону {to}"},
	"sim.news.spread.1": {"tr": "Okyanus akıntıları deniz krizini {from} bölgesinden {to} bölgesine taşıyor", "en": "Ocean currents carry the marine crisis from {from} to {to}", "ru": "Океанические течения переносят морской кризис из {from} в {to}"},
	"sim.news.spread.2": {"tr": "Gözlem şamandıraları: {to}, {from} kaynaklı kirlenmeden etkilendi", "en": "Monitoring buoys: {to} hit by contamination from {from}", "ru": "Буи слежения: акватория {to} загрязнена стоками из {from}"},

	# --- News: region alarms and recoveries (variants) ---
	"sim.news.critical.0": {"tr": "{region} ekolojik acil durum bölgesi ilan edildi", "en": "{region} declared an ecological emergency zone", "ru": "{region} объявлен зоной экологической катастрофы"},
	"sim.news.critical.1": {"tr": "{region} bölgesinde alarm: ekosistem çöküşün eşiğinde", "en": "Alarm in {region}: scientists warn the ecosystem is near collapse", "ru": "Тревога в {region}: ученые заявляют о риске коллапса экосистемы"},
	"sim.news.recovered.0": {"tr": "{region} dönüm noktasını aştı: toparlanma teyit edildi", "en": "{region} turns the corner: scientists confirm a recovery", "ru": "{region} идет на поправку: биологи подтверждают восстановление"},
	"sim.news.recovered.1": {"tr": "{region} bölgesinden iyi haber: berrak sular ve balıklar geri dönüyor", "en": "Good news from {region}: clear water and fish are returning", "ru": "Добрые вести из {region}: вода очищается, возвращается рыба"},

	# --- News: climate and economy ---
	"sim.news.temp": {"tr": "Isınma +{temp}°C seviyesini aştı: okyanus yüzeyi hızla ısınıyor", "en": "Warming passes +{temp}°C: global sea surface temperatures surge", "ru": "Потепление превысило +{temp}°C: температура поверхности океана стремительно растет"},
	"sim.news.temp_alarm": {"tr": "İklim alarmı: ısınma +{temp}°C üstünde, küresel mercan resifleri tehlikede", "en": "Climate alarm: warming tops +{temp}°C, coral reefs in danger worldwide", "ru": "Климатическая тревога: потепление выше +{temp}°C, рифы под угрозой"},
	"sim.news.depleted": {"tr": "Koalisyon kasası ve siyasi destek tükendi: misyon büyük tehlikede", "en": "Coalition coffers and political capital run dry: the mission is at risk", "ru": "Казна коалиции и политическая поддержка исчерпаны: миссия под угрозой"},

	# --- News: policy adoptions, by branch ---
	"sim.news.adopted.protect": {"tr": "Okyanuslar için yeni koruma: koalisyon {name} politikasını kabul etti", "en": "New protection for the ocean: the coalition adopts {name}", "ru": "Новая защита океана: коалиция утвердила политику {name}"},
	"sim.news.adopted.source": {"tr": "Kirlilik kaynağında kesildi: koalisyon {name} adımını attı", "en": "Pollution cut at the source: the coalition adopts {name}", "ru": "Загрязнение остановлено у истока: коалиция ввела {name}"},
	"sim.news.adopted.science": {"tr": "Bilimsel atılım: koalisyon {name} programını başlattı", "en": "Science push: the coalition launches {name}", "ru": "Научный прорыв: коалиция запускает программу {name}"},
	"sim.news.adopted.economy": {"tr": "Mavi ekonomi anlaşması: koalisyon {name} konusunda uzlaştı", "en": "Blue economy deal: the coalition agrees on {name}", "ru": "Сделка синей экономики: коалиция согласовала {name}"},

	# --- News: decision card outcomes ---
	"sim.news.event.oil_spill.a": {"tr": "Bariyerler tuttu: ekipler {region} açıklarındaki petrol sızıntısını temizledi", "en": "Booms hold: crews skim the offshore oil spill in {region}", "ru": "Боны удержали нефть: службы ликвидировали разлив в {region}"},
	"sim.news.event.oil_spill.b": {"tr": "Petrol tabakası {region} sahillerini ve resiflerini kapladı", "en": "Oil slick blackens the shores and reefs of {region}", "ru": "Нефтяное пятно загрязнило побережье региона {region}"},
	"sim.news.event.heatwave.a": {"tr": "Gölgelendirme ve koruma önlemleri {region} resiflerini ağarmadan kurtardı", "en": "Shading and closures shield the reefs of {region} from bleaching", "ru": "Защитные меры спасли рифы от обесцвечивания в регионе {region}"},
	"sim.news.event.heatwave.b": {"tr": "Kitlesel mercan ağarması: sıcak dalga {region} resiflerini kavurdu", "en": "Mass coral bleaching: a marine heatwave scorches the reefs of {region}", "ru": "Массовое обесцвечивание: тепловая волна поразила рифы в {region}"},
	"sim.news.event.lobby_pressure.a": {"tr": "Koalisyon plastik ve nakliye lobisine karşı geri adım atmadı", "en": "The coalition stands firm against the plastics and shipping lobby", "ru": "Коалиция выдержала давление промышленного лобби"},
	"sim.news.event.lobby_pressure.b": {"tr": "Sanayi anlaşması imzalandı: çevreciler kirlilik açığına karşı uyardı", "en": "Industry deal signed: green groups warn of a pollution loophole", "ru": "Подписана сделка с бизнесом: экологи предупреждают о лазейках"},
	"sim.news.event.greenwashing.a": {"tr": "Koalisyon 'yeşil aklama' yapan sponsoru bıraktı ve denetim raporunu yayımladı", "en": "The coalition drops its greenwashing sponsor and publishes a full audit", "ru": "Коалиция расторгла контракт с гринвошинг-спонсором и открыла аудит"},
	"sim.news.event.greenwashing.b": {"tr": "Koalisyon sessiz kaldıkça yeşil aklama skandalı büyüyor", "en": "Greenwashing scandal deepens as the coalition stays silent", "ru": "Скандал с псевдоэкологией разрастается из-за молчания властей"},
	"sim.news.event.fishers_coop.a": {"tr": "{region} sularında kril avcılığı sınırlandırıldı, besin zinciri korundu", "en": "Krill harvesting capped in {region}, safeguarding the polar food web", "ru": "Вылов криля в {region} ограничен, пищевая цепь защищена"},
	"sim.news.event.fishers_coop.b": {"tr": "Müzakereler tıkandı, {region} sularında aşırı kril avcılığı sürüyor", "en": "Talks collapse as industrial fleets strip krill stocks in {region}", "ru": "Переговоры сорваны: флотилии продолжают истощать запасы криля в {region}"},
	"sim.news.event.tourism_surge.a": {"tr": "Kutup rotası kısıtlamaları {region} buzullarını ve yaşam alanlarını korudu", "en": "Polar route restrictions protect ice habitats in {region}", "ru": "Ограничения полярного судоходства защитили экосистему в регионе {region}"},
	"sim.news.event.tourism_surge.b": {"tr": "{region} buzulları erirken ticari gemi trafiği kirliliği artırdı", "en": "Melting ice in {region} opens shipping lanes, driving up pollution", "ru": "Таяние льдов в {region} открыло пути судам ценой роста загрязнения"},
	"sim.news.event.mucilage.a": {"tr": "Nehir bariyerleri ve toplayıcı filolar {region} plastik akışını durdurdu", "en": "River barriers and skimmer fleets halt the plastic surge in {region}", "ru": "Барьеры и очистные катера остановили поток пластика в акватории {region}"},
	"sim.news.event.mucilage.b": {"tr": "Müdahale gecikirken plastik ve alg patlaması {region} geneline yayıldı", "en": "Plastic and algal bloom spreads across {region} while action is delayed", "ru": "Пластик и водоросли заполонили {region}, пока ученые исследовали пробы"},
	"sim.news.event.foreign_trawlers.a": {"tr": "Devriye filoları {region} çöp girdabındaki hayalet ağları ve kaçak gemileri temizledi", "en": "Patrol fleets clear ghost nets and dark trawlers from {region}", "ru": "Патрульные суда очистили {region} от брошенных сетей и браконьеров"},
	"sim.news.event.foreign_trawlers.b": {"tr": "Diplomasi sürerken hayalet ağlar ve kaçak troller {region} sularını talan etti", "en": "Ghost nets and dark trawlers strip marine life in {region} during talks", "ru": "Пока шли переговоры, траулеры и брошенные сети опустошили {region}"},
	"sim.news.event.caretta_nesting.a": {"tr": "Koruma ekipleri yuvalama alanlarını güvenceye aldı: {region} bayrak türleri çoğalıyor", "en": "Rangers guard breeding grounds: flagship species thrive in {region}", "ru": "Волонтеры защитили места размножения: флаговые виды в {region} спасены"},
	"sim.news.event.caretta_nesting.b": {"tr": "Kıyı ışıklandırması ve gürültü {region} üreme alanlarına zarar verdi", "en": "Coastal lights and noise disrupt breeding grounds in {region}", "ru": "Береговые огни и шум нарушили размножение редких видов в {region}"},
	"sim.news.event.summit_2031.a": {"tr": "Küresel Okyanus Zirvesi 2031: bağlayıcı plastik sözleşmesinde uzlaşıldı", "en": "Global Ocean Summit 2031: a binding plastics pact is agreed", "ru": "Глобальный океанический саммит 2031: утвержден обязательный пакт по пластику"},
	"sim.news.event.summit_2031.b": {"tr": "Küresel Okyanus Zirvesi 2031: bağışlar alındı, plastik paktı rafa kaldırıldı", "en": "Global Ocean Summit 2031: donors pay out, the plastics pact is shelved", "ru": "Океанический саммит 2031: гранты получены, соглашение по пластику заморожено"},
	"sim.news.event.summit_2036.a": {"tr": "Küresel Okyanus Zirvesi 2036: tüm okyanuslarda yeni deniz rezervleri ilan edildi", "en": "Global Ocean Summit 2036: new marine reserves declared worldwide", "ru": "Океанический саммит 2036: по всему миру объявлены новые морские заповедники"},
	"sim.news.event.summit_2036.b": {"tr": "Küresel Okyanus Zirvesi 2036: iklim fonu aktarıldı, yeni rezerv ilan edilmedi", "en": "Global Ocean Summit 2036: climate finance banked, no new reserves", "ru": "Океанический саммит 2036: транш климатического фонда освоен без расширения зон охраны"},
	"sim.news.event.summit_2041.a": {"tr": "Küresel Okyanus Zirvesi 2041: son beş yıl için karbon sınırı imzalandı", "en": "Global Ocean Summit 2041: a carbon cap is signed for the last five years", "ru": "Итоговый океанический саммит 2041: подписано ограничение углеродных выбросов"},
	"sim.news.event.summit_2041.b": {"tr": "Küresel Okyanus Zirvesi 2041: büyüme öncelik oldu, emisyonlar artmaya devam ediyor", "en": "Global Ocean Summit 2041: growth comes first and emissions keep rising", "ru": "Итоговый океанический саммит 2041: рост экономики в приоритете, выбросы растут"},
}
