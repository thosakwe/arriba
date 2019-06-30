import React from 'react';
import Button from '@material-ui/core/Button'
import Dialog from '@material-ui/core/Dialog'
import DialogTitle from '@material-ui/core/DialogTitle'

export default ({onToken}) => {
  let wnd;
  const doAuth = () => {
    function listener(e) {
      wnd && wnd.close();
      onToken(e.detail);
      window.removeEventListener('token', listener);
    }

    window.addEventListener('token', listener);
    window.open('/auth/google', 'width=600,height=400');
  };

  function doToken(token) {
    const opts = {method: 'POST', headers: {authorization: `Bearer ${token}`, accept: 'application/json'}};
    window.localStorage.removeItem('token');
    fetch('/auth/token', opts)
      .then(res => {
        if (res.ok) return res.json();
        else throw new Error(res.status.toString());
      })
      .then(auth => onToken(auth.token))
      .catch(() => null);
    onToken(token);
  }

  if (false && 'credentials' in navigator) {
    navigator.credentials.get({password: true}).then(credential => {
      if (credential) {
        doToken(credential.password);
      }
    }).catch(e => {
      console.error(e);
    });
  } else if (window.localStorage.token) {
    doToken(window.localStorage.token);
  }


  return (
    <Dialog open={true}>
      <DialogTitle>Log in with Google</DialogTitle>
      <div style={{padding: '1em', textAlign: 'center'}}>
        <Button onClick={doAuth}>Click here</Button>
      </div>
    </Dialog>);

  return <div>
    <h1>Arriba</h1>
    <button onClick={doAuth}>Click here to sign in with Google.</button>
  </div>
};
