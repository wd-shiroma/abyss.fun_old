import { connect } from 'react-redux';
import TextIconButton from '../components/text_icon_button';
import { changeComposeConsiderationness } from '../../../actions/compose';
import { injectIntl, defineMessages } from 'react-intl';

const messages = defineMessages({
  title: { id: 'compose_form.consideration', defaultMessage: 'Hide text behind warning' },
});

const mapStateToProps = (state, { intl }) => ({
  label: '考察',
  title: intl.formatMessage(messages.title),
  active: state.getIn(['compose', 'consideration']),
  ariaControls: 'cw-consideration-input',
});

const mapDispatchToProps = dispatch => ({

  onClick () {
    dispatch(changeComposeConsiderationness());
  },

});

export default injectIntl(connect(mapStateToProps, mapDispatchToProps)(TextIconButton));
