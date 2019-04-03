import TimeAgo from 'react-timeago'
import enStrings from 'react-timeago/lib/language-strings/en'
import buildFormatter from 'react-timeago/lib/formatters/buildFormatter'

const cnStrings = {
  prefixAgo: null,
  prefixFromNow: null,
  suffixAgo: '前',
  suffixFromNow: '之后',
  seconds: '不到 1 分钟',
  minute: '大约 1 分钟',
  minutes: '%d 分钟',
  hour: '大约 1 小时',
  hours: '大约 %d 小时',
  day: '1 天',
  days: '%d 天',
  month: '大约 1 个月',
  months: '%d 月',
  year: '大约 1 年',
  years: '%d 年',

  wordSeparator: ''
};

const metaLocale = document.querySelector('meta[name=locale]');
let locale = "en";
if (metaLocale) {
  locale = metaLocale.getAttribute("content");
}
let formatter;
if (locale === "zh-CN") {
  formatter = buildFormatter(cnStrings)
} else {
  formatter = buildFormatter(enStrings)
}



export class Timeago extends React.Component {
  render() {
    const { value } = this.props;

    return <TimeAgo date={value} formatter={formatter} />
  }
}
