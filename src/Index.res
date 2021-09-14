module Carousel = {
  @react.component
  let make = () => {
    let (currentIndex, setCurrentIndex) = React.useState(() => 0)

    React.useEffect0(() => {
      let timerId = Js.Global.setInterval(() => {
        setCurrentIndex(currentIndex => mod(currentIndex + 1, 5))
      }, 600)

      Some(() => Js.Global.clearInterval(timerId))
    })

    {
      switch currentIndex {
      | 0 => <Next.Image src={Next.require("../public/assets/0.png")} />
      | 1 => <Next.Image src={Next.require("../public/assets/1.png")} />
      | 2 => <Next.Image src={Next.require("../public/assets/2.png")} />
      | 3 => <Next.Image src={Next.require("../public/assets/3.png")} />
      | 4 => <Next.Image src={Next.require("../public/assets/4.png")} />
      | _ => React.null
      }
    }
  }
}

@react.component
let make = () => {
  let wallet = Web3.useWallet()
  let contract = Web3.useContractMethods()

  React.useEffect0(() => {
    let _ = contract.getTotalSupply()
    None
  })

  <div className="h-screen flex md:tems-center md:justify-center">
    <div className="container p-5 md:px-16 md:py-12 flex flex-col flex-col-reverse md:flex-row justify-between">
      <div className="flex flex-col flex-grow p-0 md:px-4">
        <Next.Head> <title> {"Fantom Kittens"->React.string} </title> </Next.Head>
        <h1 className="text-4xl font-semibold">
          {"Welcome to "->React.string}
          {<span className="text-blue-500"> {"Fantom Kittens"->React.string} </span>}
        </h1>
        {switch wallet.status {
        | #disconnected
        | #connecting =>
          <button
            type_="button"
            className="bg-blue-500 py-5 px-5 uppercase text-white font-bold mt-auto"
            disabled={wallet.status == #connecting}
            onClick={_ => {
              let _ = wallet.connect(. #injected)
            }}>
            {"Connect wallet"->React.string}
          </button>
        | #error => `Something went wrong. Try reloading your page.`->React.string
        | #connected => <>
            <div className="max-w-3xl">
            <h1 className="text-xl">
            <span className="overflow-ellipsis">
              {`Welcome, ${wallet.account
                ->Js.Nullable.toOption
                ->Belt.Option.getWithDefault("")}`->React.string}
                </span>
            </h1>
            </div>
            <p>
              {switch contract.totalSupply {
              | None => "Remaining ..."->React.string
              | Some(totalSupply) => `Remaining ${totalSupply->string_of_int}/420`->React.string
              }}
            </p>
            <button
              type_="button"
              className="bg-green-500 py-5 px-5 uppercase text-white font-bold mt-auto"
              disabled={wallet.status == #connecting}
              onClick={_ => {
                let _ = wallet.connect(. #injected)
                let _ = contract.claim()
              }}>
              {`Claim one kitten for 4.2 FTM`->React.string}
            </button>
          </>
        }}
      </div>
      <div className="flex items-center justify-center"> <Carousel /> </div>
    </div>
  </div>
}
