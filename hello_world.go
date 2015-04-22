package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
)

func main() {
	resp, err := http.Get("http://www.ebay.de/sch/Notebooks-Netbooks-/175672/i.html?_from=R40&ghostText=&LH_Complete=1&LH_Sold=1&_mPrRngCbx=1&_udlo=100&_udhi=250&_nkw=thinkpad+x201&_ipg=200&rt=nc")
	if err != nil {
		log.Fatal(err)
	}
	content, err := ioutil.ReadAll(resp.Body)
	resp.Body.Close()
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("%s", content)
}

