import React from 'react';
import Immutable from 'immutable';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { Link } from 'react-router-dom';

const announcements = Immutable.fromJS([
  {
    body: 'アビス関連情報、当インスタンスの使い方などはこちら',
    links: [
      { href: 'https://wiki.abyss.fun', body: 'Ｗｉｋｉ' },
    ],
  },
  {
    body: 'いくらでも んなぁー が聴けます',
    links: [
      { href: 'https://click.abyss.fun', body: 'んなぁーボタン' }
    ],
  },
  {
    body: 'キーワードタイムライン',
    links: [
      { href: '/timelines/tag/mia_staff', body: 'スタッフ', link: true },
      { href: '/timelines/tag/mia_cast', body: '声優', link: true },
      { href: '/timelines/tag/mia_seekercamp', body: '監視基地', link: true },
      { href: '/timelines/tag/mia_idofront', body: '前線基地', link: true },
      { href: '/timelines/tag/mia_rikos_party', body: 'リコさん隊', link: true },
      { href: '/timelines/tag/mia_artifacts', body: '遺物', link: true },
      { href: '/timelines/tag/mia_ilblu', body: 'イルブル', link: true },
      { href: '/timelines/tag/mia_creature', body: '原生生物', link: true },
      { href: '/timelines/tag/mia_place', body: '場所', link: true },
      { href: '/timelines/tag/mia_nether_gryph', body: '奈落文字', link: true },
      { href: '/timelines/tag/メイドインアビス', body: '全般', link: true }
    ],
  },
  {
    body: 'おすすめタイムライン',
    links: [
      { href: '/timelines/tag/abyss_fun', body: 'Abyss.fun旧ローカル', link: true },
      { href: '/timelines/tag/theboss_tech', body: 'theboss.tech(雑談)', link: true },
    ],
  }
]);

export default class Announcements extends React.PureComponent {

  static propTypes = {
    visible: PropTypes.bool.isRequired,
    onToggle: PropTypes.func.isRequired,
  }

  render () {
    const { visible, onToggle } = this.props;
    const caretClass = visible ? 'fa fa-caret-down' : 'fa fa-caret-up';
    return (
      <div className='announcements'>
        <div className='compose__extra__header'>
          <i className='fa fa-link' />
          関連リンク
          <button className='compose__extra__header__icon' onClick={onToggle} >
            <i className={caretClass} />
          </button>
        </div>
        { visible && (
          <ul>
            {announcements.map((announcement, idx) => (
              <li key={idx}>
                <div className='announcements__icon'>
                  <i className='fa fa-bookmark' />
                </div>
                <div className='announcements__body'>
                  <p>{announcement.get('body')}</p>
                  <div className='links'>
                    {announcement.get('links').map((link, i) => (
                      link.get('link') === true
                      ? <Link to={link.get('href')}>
                          {link.get('body')}
                        </Link>
                      : <a href={link.get('href')} target='_blank' key={i}>
                          {link.get('body')}
                        </a>
                    ))}
                  </div>
                </div>
              </li>
            ))}
          </ul>
        )}
      </div>
    );
  }

}
