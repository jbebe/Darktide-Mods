import bg from './assets/bg.jpg'
import steam from './assets/steam.svg'
import xbox from './assets/xbox.svg'
import styles from './app.module.css'
import { JSX } from 'preact/jsx-runtime'

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
  const params = new URLSearchParams(location.hash.slice(1))
  const token = params.get('token')
  const isCallback = token !== null
  const lambdaPrefix = import.meta.env.VITE_API_URL
  
  function copyToken(evt: JSX.TargetedMouseEvent<HTMLInputElement>): void {
    navigator.clipboard.writeText(token!)
    const copy = evt.currentTarget.nextSibling as HTMLDivElement
    copy.style.opacity = '1'
    setTimeout(() => copy.style.opacity = '0', 2000);
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
            {isCallback ? <>
              <p style={{ textAlign: 'center' }}>
                Copy the following code and paste it in your game
              </p>
              <div className={styles.buttonContainer}>
                <input type="text" defaultValue={token} readOnly onClick={(evt) => copyToken(evt)} />
                <div className={styles.copy}>Copied</div>
              </div>
            </> 
            : <>
              <p style={{ textAlign: 'center' }}>
                Login to your gaming platform to get an <Color value='blue'>access token</Color>
              </p>
              <div className={styles.buttonContainer}>
                <Button href={`${lambdaPrefix}/auth/steam`} icon={steam}>Steam</Button>
                <Button disabled icon={xbox}>Xbox</Button>
              </div>
              </>}
            <hr />
            <h4>What is this?</h4>
            <p>
              Loves Me, Loves Me Not is a Darktide mod.
              It helps you rate people (very bad/very good) during missions for your convenience.
              This information is stored locally so you can rate as many people as you want.
              On the other hand, if you turn on <Color value='yellow'>community rating</Color> in the mod settings, your ratings are synced to a server
              where everyone else using the mod can see it, helping the community avoid toxic players and quickly noticing good players.
            </p>
            <h4>So that means I can be falsely accused? Why not?</h4>
            <p>
              From day one, the algorithm for ratings takes into account false single and even group votes.
              In order to be rated toxic, you need some ranked players to rate you over time. 
              To answer your question, people can't just rate you bad out of spite. 
              That would not be a good feature.
            </p>
            <h4>How can I access <Color value='yellow'>community rating</Color>?</h4>
            <p>
              You need an <Color value='blue'>access token</Color>.
              This token binds to your gaming platform account (Steam/Xbox), meaning 
              for one Steam account you get one access token.
              If you acquired said token, copy it, open Darktide and paste it into the popup input field.
              You are ready to send and receive community ratings.
            </p>
            <h4>Is that platform login button safe?</h4>
            <p>
              The login button redirects you to the gaming platform.
              The only information I obtain through said platform is your account id 
              if the login succeeds.
            </p>
            <h4>Why didn't I get my <Color value='blue'>token</Color>?</h4>
            <ul>
              <li>You cancelled your gaming platform login flow</li>
              <li>Your profile is not public</li>
              <li>You do not own Darktide</li>
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
