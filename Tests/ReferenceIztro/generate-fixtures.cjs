const fs = require('node:fs');
const path = require('node:path');
const { astro } = require('iztro');
const { solar2lunar } = require('lunar-lite');
const { Solar } = require('lunar-typescript');

const cases = [
  { id: 'canonical', type: 'solar', date: '2000-8-16', timeIndex: 2, gender: '女', fixLeap: true },
  { id: 'before-lunar-new-year', type: 'solar', date: '1990-1-1', timeIndex: 0, gender: '男', fixLeap: true },
  { id: 'leap-month-late-rat', type: 'solar', date: '2023-3-23', timeIndex: 12, gender: '女', fixLeap: true },
  { id: 'leap-month-no-fix', type: 'solar', date: '2023-4-10', timeIndex: 6, gender: '男', fixLeap: false },
  { id: 'lunar-entry-point', type: 'lunar', date: '2000-7-17', timeIndex: 2, gender: '女', isLeapMonth: false, fixLeap: true },
  { id: 'jia-zi-cycle', type: 'solar', date: '1924-2-15', timeIndex: 1, gender: '男', fixLeap: true },
  { id: 'mid-century', type: 'solar', date: '1955-6-30', timeIndex: 11, gender: '女', fixLeap: true },
  { id: 'winter-1966', type: 'solar', date: '1966-12-21', timeIndex: 4, gender: '男', fixLeap: true },
  { id: 'summer-1977', type: 'solar', date: '1977-7-7', timeIndex: 8, gender: '女', fixLeap: true },
  { id: 'dragon-1988', type: 'solar', date: '1988-10-1', timeIndex: 10, gender: '男', fixLeap: true },
  { id: 'new-year-eve-2010', type: 'solar', date: '2010-2-13', timeIndex: 12, gender: '女', fixLeap: true },
  { id: 'new-year-2010', type: 'solar', date: '2010-2-14', timeIndex: 0, gender: '女', fixLeap: true },
  { id: 'leap-month-2012', type: 'solar', date: '2012-5-21', timeIndex: 3, gender: '男', fixLeap: true },
  { id: 'leap-month-2012-late', type: 'solar', date: '2012-6-8', timeIndex: 9, gender: '男', fixLeap: true },
  { id: 'winter-2033', type: 'solar', date: '2033-12-22', timeIndex: 5, gender: '女', fixLeap: true },
  { id: 'future-2050', type: 'solar', date: '2050-9-9', timeIndex: 7, gender: '男', fixLeap: true },
  { id: 'future-2099', type: 'solar', date: '2099-11-30', timeIndex: 12, gender: '女', fixLeap: true },
];

function compactStar(star) {
  return {
    name: star.name,
    type: star.type,
    scope: star.scope,
    brightness: star.brightness || null,
    mutagen: star.mutagen || null,
  };
}

function compact(chart) {
  return {
    gender: chart.gender,
    solarDate: chart.solarDate,
    time: chart.time,
    timeRange: chart.timeRange,
    sign: chart.sign,
    zodiac: chart.zodiac,
    earthlyBranchOfSoulPalace: chart.earthlyBranchOfSoulPalace,
    earthlyBranchOfBodyPalace: chart.earthlyBranchOfBodyPalace,
    soul: chart.soul,
    body: chart.body,
    fiveElementsClass: chart.fiveElementsClass,
    lunar: {
      year: chart.rawDates.lunarDate.lunarYear,
      month: chart.rawDates.lunarDate.lunarMonth,
      day: chart.rawDates.lunarDate.lunarDay,
      isLeapMonth: chart.rawDates.lunarDate.isLeap,
    },
    pillars: {
      yearly: chart.rawDates.chineseDate.yearly.join(''),
      monthly: chart.rawDates.chineseDate.monthly.join(''),
      daily: chart.rawDates.chineseDate.daily.join(''),
      hourly: chart.rawDates.chineseDate.hourly.join(''),
    },
    palaces: chart.palaces.map((palace) => ({
      index: palace.index,
      name: palace.name,
      isBodyPalace: palace.isBodyPalace,
      isOriginalPalace: palace.isOriginalPalace,
      heavenlyStem: palace.heavenlyStem,
      earthlyBranch: palace.earthlyBranch,
      majorStars: palace.majorStars.map(compactStar),
      minorStars: palace.minorStars.map(compactStar),
      adjectiveStars: palace.adjectiveStars.map(compactStar),
      changsheng12: palace.changsheng12,
      boshi12: palace.boshi12,
      jiangqian12: palace.jiangqian12,
      suiqian12: palace.suiqian12,
      decadal: palace.decadal,
      ages: palace.ages,
    })),
  };
}

const fixtures = cases.map((item) => {
  const chart = item.type === 'solar'
    ? astro.bySolar(item.date, item.timeIndex, item.gender, item.fixLeap, 'zh-CN')
    : astro.byLunar(item.date, item.timeIndex, item.gender, item.isLeapMonth, item.fixLeap, 'zh-CN');
  return { input: item, expected: compact(chart) };
});

const target = path.resolve(__dirname, '../ZiweiKitTests/Fixtures/iztro-2.5.8.json');
fs.mkdirSync(path.dirname(target), { recursive: true });
fs.writeFileSync(target, `${JSON.stringify(fixtures, null, 2)}\n`);
console.log(`Wrote ${fixtures.length} fixtures to ${target}`);

const horoscopeCases = [
  { id: 'adult-female', birthDate: '2000-8-16', birthTimeIndex: 2, gender: '女', targetDate: '2026-7-28', targetTimeIndex: 6 },
  { id: 'adult-male', birthDate: '1990-1-1', birthTimeIndex: 0, gender: '男', targetDate: '2023-3-23', targetTimeIndex: 12 },
  { id: 'childhood', birthDate: '2020-5-5', birthTimeIndex: 8, gender: '男', targetDate: '2023-4-10', targetTimeIndex: 3 },
  { id: 'future', birthDate: '2033-12-22', birthTimeIndex: 5, gender: '女', targetDate: '2050-9-9', targetTimeIndex: 7 },
];

function compactPeriod(period) {
  return {
    index: period.index,
    name: period.name,
    heavenlyStem: period.heavenlyStem,
    earthlyBranch: period.earthlyBranch,
    palaceNames: period.palaceNames,
    mutagen: period.mutagen,
    stars: period.stars?.map((palace) => palace.map(compactStar)) ?? [],
    yearlyDecStar: period.yearlyDecStar ?? null,
  };
}

const horoscopeFixtures = horoscopeCases.map((item) => {
  const chart = astro.bySolar(item.birthDate, item.birthTimeIndex, item.gender, true, 'zh-CN');
  const horoscope = chart.horoscope(item.targetDate, item.targetTimeIndex);
  const lunar = solar2lunar(item.targetDate);
  return {
    input: item,
    expected: {
      solarDate: horoscope.solarDate,
      lunar: { year: lunar.lunarYear, month: lunar.lunarMonth, day: lunar.lunarDay, isLeapMonth: lunar.isLeap },
      decadal: compactPeriod(horoscope.decadal),
      age: horoscope.age,
      yearly: compactPeriod(horoscope.yearly),
      monthly: compactPeriod(horoscope.monthly),
      daily: compactPeriod(horoscope.daily),
      hourly: compactPeriod(horoscope.hourly),
    },
  };
});

const horoscopeTarget = path.resolve(__dirname, '../ZiweiKitTests/Fixtures/iztro-2.5.8-horoscope.json');
fs.writeFileSync(horoscopeTarget, `${JSON.stringify(horoscopeFixtures, null, 2)}\n`);
console.log(`Wrote ${horoscopeFixtures.length} horoscope fixtures to ${horoscopeTarget}`);

const configuredCases = [
  {
    id: 'exact-li-chun-boundary', type: 'lunar', date: '1999-12-29', timeIndex: 2,
    gender: '女', isLeapMonth: true, fixLeap: true,
    config: { yearDivide: 'exact', horoscopeDivide: 'exact' }, astroType: 'heaven',
  },
  {
    id: 'late-rat-current', type: 'solar', date: '1987-9-23', timeIndex: 12,
    gender: '女', fixLeap: true,
    config: { yearDivide: 'normal', horoscopeDivide: 'normal', dayDivide: 'current' }, astroType: 'heaven',
  },
  {
    id: 'zhongzhou-heaven', type: 'solar', date: '1979-8-21', timeIndex: 7,
    gender: '男', fixLeap: true,
    config: { algorithm: 'zhongzhou' }, astroType: 'heaven',
  },
  {
    id: 'zhongzhou-earth', type: 'solar', date: '1979-8-21', timeIndex: 7,
    gender: '男', fixLeap: true,
    config: { algorithm: 'zhongzhou' }, astroType: 'earth',
  },
  {
    id: 'zhongzhou-human', type: 'solar', date: '1979-8-21', timeIndex: 8,
    gender: '男', fixLeap: true,
    config: { algorithm: 'zhongzhou' }, astroType: 'human',
  },
  {
    id: 'custom-mutagen-brightness', type: 'solar', date: '2000-8-16', timeIndex: 2,
    gender: '女', fixLeap: true,
    config: {
      mutagens: { 庚: ['太阳', '武曲', '天同', '天相'] },
      brightness: { 紫微: Array(12).fill('庙') },
    },
    astroType: 'heaven',
  },
];

const configuredFixtures = configuredCases.map((item) => {
  astro.config({
    yearDivide: 'normal', horoscopeDivide: 'normal', ageDivide: 'normal',
    dayDivide: 'forward', algorithm: 'default',
    mutagens: { 庚: ['太阳', '武曲', '太阴', '天同'] },
    brightness: { 紫微: ['旺', '旺', '得', '旺', '庙', '庙', '旺', '旺', '得', '旺', '平', '庙'] },
  });
  const chart = astro.withOptions({
    type: item.type,
    dateStr: item.date,
    timeIndex: item.timeIndex,
    gender: item.gender,
    isLeapMonth: item.isLeapMonth,
    fixLeap: item.fixLeap,
    astroType: item.astroType,
    config: item.config,
    language: 'zh-CN',
  });
  return { input: item, expected: compact(chart) };
});

const configuredTarget = path.resolve(__dirname, '../ZiweiKitTests/Fixtures/iztro-2.5.8-configured.json');
fs.writeFileSync(configuredTarget, `${JSON.stringify(configuredFixtures, null, 2)}\n`);
console.log(`Wrote ${configuredFixtures.length} configured fixtures to ${configuredTarget}`);

// `astro.config` is global in iztro. Restore values changed by the custom case
// before generating independently configured horoscope fixtures.
astro.config({
  yearDivide: 'normal', horoscopeDivide: 'normal', ageDivide: 'normal',
  dayDivide: 'forward', algorithm: 'default',
  mutagens: { 庚: ['太阳', '武曲', '太阴', '天同'] },
  brightness: { 紫微: ['旺', '旺', '得', '旺', '庙', '庙', '旺', '旺', '得', '旺', '平', '庙'] },
});

const configuredHoroscopeCases = [
  {
    id: 'birthday-divider', type: 'solar', birthDate: '2000-8-16', birthTimeIndex: 2, gender: '女',
    targetDate: '2023-8-19', targetTimeIndex: 2, config: { ageDivide: 'birthday' },
  },
  {
    id: 'exact-horoscope-divider', type: 'lunar', birthDate: '1979-12-28', birthTimeIndex: 0, gender: '女',
    targetDate: '1980-2-14', targetTimeIndex: 0,
    config: { yearDivide: 'normal', horoscopeDivide: 'exact' },
  },
];

const configuredHoroscopeFixtures = configuredHoroscopeCases.map((item) => {
  astro.config({
    yearDivide: 'normal', horoscopeDivide: 'normal', ageDivide: 'normal',
    dayDivide: 'forward', algorithm: 'default',
    mutagens: { 庚: ['太阳', '武曲', '太阴', '天同'] },
    brightness: { 紫微: ['旺', '旺', '得', '旺', '庙', '庙', '旺', '旺', '得', '旺', '平', '庙'] },
  });
  const chart = astro.withOptions({
    type: item.type, dateStr: item.birthDate, timeIndex: item.birthTimeIndex,
    gender: item.gender, fixLeap: true, config: item.config, language: 'zh-CN',
  });
  const horoscope = chart.horoscope(item.targetDate, item.targetTimeIndex);
  const lunar = solar2lunar(item.targetDate);
  return {
    input: item,
    expected: {
      solarDate: horoscope.solarDate,
      lunar: { year: lunar.lunarYear, month: lunar.lunarMonth, day: lunar.lunarDay, isLeapMonth: lunar.isLeap },
      decadal: compactPeriod(horoscope.decadal), age: horoscope.age,
      yearly: compactPeriod(horoscope.yearly), monthly: compactPeriod(horoscope.monthly),
      daily: compactPeriod(horoscope.daily), hourly: compactPeriod(horoscope.hourly),
    },
  };
});

const configuredHoroscopeTarget = path.resolve(
  __dirname, '../ZiweiKitTests/Fixtures/iztro-2.5.8-configured-horoscope.json',
);
fs.writeFileSync(configuredHoroscopeTarget, `${JSON.stringify(configuredHoroscopeFixtures, null, 2)}\n`);
console.log(`Wrote ${configuredHoroscopeFixtures.length} configured horoscope fixtures to ${configuredHoroscopeTarget}`);

const jieNames = ['小寒', '立春', '惊蛰', '清明', '立夏', '芒种', '小暑', '立秋', '白露', '寒露', '立冬', '大雪'];
const calendricalFixtures = [];
for (const year of [1901, 1950, 2000, 2050, 2099]) {
  const table = Solar.fromYmd(year, 6, 15).getLunar().getJieQiTable();
  for (const name of jieNames) {
    const date = table[name].toYmd();
    for (const timeIndex of [0, 12]) {
      astro.config({
        yearDivide: 'exact', horoscopeDivide: 'exact', ageDivide: 'normal',
        dayDivide: 'forward', algorithm: 'default',
      });
      const chart = astro.bySolar(date, timeIndex, '男', true, 'zh-CN');
      calendricalFixtures.push({
        input: { id: `${year}-${name}-${timeIndex}`, date, timeIndex },
        expected: {
          zodiac: chart.zodiac,
          yearly: chart.rawDates.chineseDate.yearly.join(''),
          monthly: chart.rawDates.chineseDate.monthly.join(''),
          daily: chart.rawDates.chineseDate.daily.join(''),
          hourly: chart.rawDates.chineseDate.hourly.join(''),
        },
      });
    }
  }
}

const calendricalTarget = path.resolve(__dirname, '../ZiweiKitTests/Fixtures/iztro-2.5.8-solar-terms.json');
fs.writeFileSync(calendricalTarget, `${JSON.stringify(calendricalFixtures, null, 2)}\n`);
console.log(`Wrote ${calendricalFixtures.length} solar-term fixtures to ${calendricalTarget}`);
