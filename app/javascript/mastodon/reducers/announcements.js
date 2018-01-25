import Immutable from 'immutable';
import { TOGGLE_ANNOUNCEMENTS } from '../actions/announcements';

const initialState = Immutable.Map({
  visible: true,
});

export default function announcements(state = initialState, action) {
  switch(action.type) {
  case TOGGLE_ANNOUNCEMENTS:
    return state.set('visible', !state.get('visible'));
  default:
    return state;
  }
};
