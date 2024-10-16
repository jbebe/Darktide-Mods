import bg from './assets/bg.jpg'
import steam from './assets/steam.svg'
import xbox from './assets/xbox.svg'
import styles from './app.module.css'
import { JSX } from 'preact/jsx-runtime'

enum ErrorCode {
  Internal = 'Internal',
  NoOwnership = 'NoOwnership',
  AuthCancelled = 'AuthCancelled',
}

function merge(...args: (string | { [_: string]: boolean })[]){
  const result = []
  for (const value of args){
    if (typeof value === 'string'){
      result.push(value)
    }
    else if (typeof value === 'object'){
      Object.entries(value)
        .filter(([_, enabled]) => enabled)
        .forEach(([name, _]) => result.push(name))
    }
  }
  return result.join(' ')
}

function Header(){
  return (
    <>
      <h1 style={{textAlign:'center', margin:0}}>Loves Me, Loves Me Not</h1>
      <h4 style={{textAlign:'center', margin:0}}>For the community, by the community</h4>
    </>
  )
}

function Decor({ position }: { position: 'top' | 'bottom' }){
  const topOrBottom = {
    [styles.top]: position === 'top',
    [styles.bottom]: position === 'bottom'
  };
  return (
    <div className={merge(styles.decorContainer, topOrBottom)}>
      <hr className={merge(styles.decor, styles.shadow, topOrBottom)} />
      <hr className={merge(styles.decor, topOrBottom)} />
    </div>
  );
}

type ButtonProps = { 
  disabled?: boolean, 
  href?: string, 
  children: string, 
  icon: any }

function Button({ children, icon, href, disabled }: ButtonProps){
  return (
    <a href={href} className={disabled ? styles.disabled : ''}>
      <img src={icon} />
      {children}
    </a>
  );
}

function Color({ children, value }: { children: string, value: 'yellow' | 'blue' }){
  const yellowOrBlue = {
    [styles.yellow]: value === 'yellow',
    [styles.blue]: value === 'blue'
  };
  return <span className={merge(yellowOrBlue)}>{children}</span>
}

export function App() {
  const errorCode = new URLSearchParams(location.search).get('error');
  const hashParams = new URLSearchParams(location.hash.slice(1))
  const token = hashParams.get('token')
  const isCallback = token !== null
  const lambdaPrefix = import.meta.env.VITE_API_URL
  
  function copyToken(evt: JSX.TargetedMouseEvent<HTMLInputElement>): void {
    navigator.clipboard.writeText(token!)
    const copy = evt.currentTarget.nextSibling as HTMLDivElement
    copy.style.opacity = '1'
    setTimeout(() => copy.style.opacity = '0', 2000);
  }
  
  function mapErrorToMessage(error: ErrorCode){
    const returnToHome = <><br/><a href="/">Click here</a> to return to the homepage.</>
    switch (error){
      case ErrorCode.AuthCancelled:
        return <>You cancelled the authentication flow.{returnToHome}</>
      case ErrorCode.NoOwnership:
        return <>According to your chosen platform you do not own Darktide. Thus we will not create an access token.{returnToHome}</>
      case ErrorCode.Internal:
        return <>An internal server error occurred. Let me know if I can help with it on Discord.{returnToHome}</>
    }
  }

  if (isCallback){
    const newUrl = location.href.replace(location.hash, '');
    history.replaceState({}, '', newUrl)
  }

  return (
    <>
      <div className={merge(styles.background, styles.scanlines)} style={{backgroundImage: `url(${bg})`}} />
      <div className={styles.layout}>
        <div className={styles.container}>
          <Decor position='top' />
          <div className={styles.content}>
            <Header />
            <hr />
            {errorCode && <div className={styles.error}>{mapErrorToMessage(errorCode as ErrorCode)}</div>}
            {!errorCode && isCallback && <>
              <p style={{ textAlign: 'center' }}>
                Copy the following code and paste it in your game
              </p>
              <div className={styles.buttonContainer}>
                <input type="text" defaultValue={token} readOnly onClick={(evt) => copyToken(evt)} />
                <div className={styles.copy}>Copied</div>
              </div>
            </>}
            {!errorCode && !isCallback && <>
              <p style={{ textAlign: 'center' }}>
                Login to your gaming platform to get an <Color value='blue'>access token</Color>
              </p>
              <div className={styles.buttonContainer}>
                <Button href={`${lambdaPrefix}/auth/steam`} icon={steam}>Steam</Button>
                <Button href={`${lambdaPrefix}/auth/xbox`} icon={xbox}>Xbox</Button>
              </div>
            </>}
            <hr />
            <h4>How can I access <Color value='yellow'>community rating</Color>?</h4>
            <p>
              You need an <Color value='blue'>access token</Color>.
              This token binds to your gaming platform account (Steam/Xbox), meaning 
              for one Steam account you get one access token.
              If you acquired said token, copy it, head back to Darktide and paste it into the input field.
              You are ready to send and receive community ratings.
            </p>
            <h4>Are those two login buttons safe?</h4>
            <p>
              Steam:<br/>
              The Steam button redirects you to the Steam App login page.
              It is not an actual app that will be linked to your account, just a method to securely get your account id.
              Once you press Sign In, our servers receive only your account id (which is public information)
              and given that, the server queries your owned games, looking for Darktide.
              If Darktide has been found, your <Color value='blue'>access token</Color> is returned to you. 
              No information is stored at any point during this procedure.
            </p>
            <p>
              Xbox:<br/>
              The login button redirects you to the Xbox Live login page.
              If you press Cancel, you will be redirected to this page.
              If you press Accept, the server will have temporal access to some basic information of your account.
              Once your ownership of Darktide is determined, the temporal access is lost and your <Color value='blue'>access token</Color> is generated.
              No information is stored at any point during this procedure.
            </p>
            <h4>Why didn't I get my <Color value='blue'>token</Color>?</h4>
            <ul>
              <li>You cancelled your gaming platform login flow</li>
              <li>
                Your Steam profile is not public - 
                Although I tested it with a private profile, 
                the documentation says we cannot list your owned games if your profile is set to private. 
                Try it, if an error occurs, change your Steam profile to public.
              </li>
              <li>
                You do not own Darktide - 
                Xbox users might experience an issue where you actually own Dartkide but an error occurs.
                If you don't have at least one achivement, our servers cannot determine if you own Dartkide. 
                Sorry for that, it's a limitation of the Xbox platform.
              </li>
            </ul>
            <hr />
            <p style={{ textAlign: 'center'}}>
              bajuh@discord | <a href="https://github.com/jbebe/Darktide-Mods/tree/master/lovesmenot">GitHub project</a>
            </p>
          </div>
          <Decor position='bottom' />
        </div>
      </div>
    </>
  )
}
