*! version 1.0.1  18aug1998
program define lprplot /* partial residual plot after logistic */
	version 5.0
	if "$S_E_cmd"!="logistic" { error 301 }
	if "$S_E_wgt"!="" {
		di in red "not possible with weighted logistic"
		exit 135
	}
	local varlist "req ex max(1)"
	#delimit ;
	local options "Symbol(string) Connect(string) L1title(string)
		       T1title(string) BWidth(real .8) *" ;
	#delimit cr
	parse "`*'"
	local x "`varlist'"

	parse "$S_E_vl", parse(" ")
	local y "`1'"

	capture local beta = _b[`x']
	if _rc {
		di in red "`x' is not in the model"
		exit 147
	}

	tempname estname
	tempvar r ksm

	quietly {
		predict `r' $S_E_if $S_E_in
		replace `r' = (`y'-`r')/(`r'*(1-`r')) + _b[`x']*`x'
		nobreak {
			estimate hold `estname'
			capture break {
				ksm `r' `x' if `r'!=. , /*
				*/ gen(`ksm') lowess bwidth(`bwidth') nograph
			}
			local rc = _rc
			estimate unhold `estname'
			if `rc' { error `rc' }
		}
	}

	if "`l1title'"=="" { local l1title "Logistic partial residual" }

	if "`t1title'"=="" { local t1title "Logistic model for `y'" }

	if "`symbol'"=="" { local symbol "s(oi)" }
	else local symbol "s(`symbol'i)"

	if "`connect'"=="" { local connect "c(.l)" }
	else local connect "c(.`connect')"

	graph `r' `ksm' `x' if `r'!=., `symbol' `connect' sort /*
	*/	t1("`t1title'") l1("`l1title'") `options'
end
exit
