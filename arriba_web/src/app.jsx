import React from 'react';
import AppBar from '@material-ui/core/AppBar'
import Fab from '@material-ui/core/Fab'
import CloudUploadIcon from '@material-ui/icons/CloudUpload'
import Landing from './landing';
import Toolbar from '@material-ui/core/Toolbar'
import Typography from '@material-ui/core/Typography'
import Queue from './queue';
import UsersList from './users';

export default class extends React.Component {
  constructor(props) {
    super(props);
    this.fileUpload = React.createRef();
    this.state = {users: [], queue: []};
  }

  handleToken(token) {
    // Connect to the server. Get a WebSocket going.
    const wsUrl = 'ws://' + window.location.host + '/ws?token=' + encodeURIComponent(token);
    const ws = new WebSocket(wsUrl);
    ws.onopen = () => {
      this.setState({token, ws});

      if (false && 'credentials' in navigator) {
        fetch('/api/me', {headers: {authorization: `Bearer ${token}`}})
          .then(res => res.json())
          .then(user => {
            navigator.credentials.store(new PasswordCredential({
              id: user.id,
              password: token,
              name: user.name,
              iconURL: user.avatar_url
            }));
          });
      } else {
        window.localStorage.setItem('token', token);
      }

      ws.onmessage = (e) => {
        const packet = JSON.parse(e.data);
        if (packet.eventName === 'join') {
          const existing = this.state.users.filter(u => u.id && u.id === packet.data.id);
          if (!existing.length)
            this.setState({users: [...this.state.users, packet.data]});
        } else if (packet.eventName === 'upload') {
          const existing = this.state.queue.filter(it => it.url && it.url === packet.data.url);
          if (!existing.length)
            this.setState({queue: [...this.state.queue, packet.data]});
        } else if (packet.eventName === 'leave') {
          const matching = this.state.users.filter(u => u.id === packet.data.id);
          console.info(matching);

          for (const user of matching) {
            const idx = this.state.users.indexOf(user);
            console.info(idx);
            if (idx !== -1) {
              const users = [...this.state.users];
              users.splice(idx, 1);
              this.setState({users});
            }
          }
        }
      };
    };
    ws.onerror = this.props.onError;
  }

  render() {
    const fabStyle = {position: 'fixed', bottom: '1em', right: '1em'};
    const hidden = {display: 'none'};
    const onFile = e => {
      if (this.fileUpload.current.files.length) {
        const file = this.fileUpload.current.files[0];
        const formData = new FormData();
        formData.append("file", file.slice(), file.name);
        const opts = {method: 'POST', body: formData, headers: {authorization: `Bearer ${this.state.token}`}};
        fetch('/api/upload', opts)
          .then(res => {
            if (res.status !== 200) {
              return res.json().then(e => {
                throw new Error(`${res.status} ${res.statusText} - ${e.message}`);
              });
            }
          })
          .catch(e => {
            // TODO: Handle this
            console.error(e);
          });
      }
    };
    const showUpload = () => {
      this.fileUpload.current.click();
    };

    if (this.state.token) {
      return (
        <div>
          <AppBar position="static">
            <Toolbar>
              <Typography variant="h6" color="inherit">
                Lobby
              </Typography>
            </Toolbar>
          </AppBar>
          {this.state.users.length > 0 && <UsersList users={this.state.users}/>}
          {this.state.queue.length > 0 && <Queue items={this.state.queue}/>}
          <input type="file" ref={this.fileUpload} onChange={onFile} style={hidden}/>
          <Fab color="primary" aria-label="Upload" style={fabStyle} onClick={showUpload}>
            <CloudUploadIcon/>
          </Fab>
        </div>)
    } else {
      return <Landing onToken={this.handleToken.bind(this)}/>;
    }
  }
}

