if [[ $ZVM_NAME == 'zsh-vi-mode' ]]; then

    # Duplicated from source ZVM, but added clipboard support.
    function zvm_yank() {
        local ret=($(zvm_calc_selection $1))
        local bpos=$ret[1] epos=$ret[2] cpos=$ret[3]
        CUTBUFFER=${BUFFER:$bpos:$((epos-bpos))}
        if [[ ${1:-$ZVM_MODE} == $ZVM_MODE_VISUAL_LINE ]]; then
            CUTBUFFER=${CUTBUFFER}$'\n'
        fi
        #### CLIPBOARD ADDITIONS - begin
        printf "%s" $CUTBUFFER | clipcopy
        #### CLIPBOARD ADDITIONS - end
        CURSOR=$bpos MARK=$epos
    }

    # Duplicated from source ZVM, but added clipboard support.
    function zvm_replace_selection() {
        local ret=($(zvm_calc_selection))
        local bpos=$ret[1] epos=$ret[2] cpos=$ret[3]
        local cutbuf=$1
        #### CLIPBOARD ADDITIONS - begin
        if [[ -n $cutbuf ]]; then
            cutbuf="$(clippaste)"
        fi
        #### CLIPBOARD ADDITIONS - end

        # If there's a replacement, we need to calculate cursor position
        if (( $#cutbuf > 0 )); then
            cpos=$(($bpos + $#cutbuf - 1))
        fi

        CUTBUFFER=${BUFFER:$bpos:$((epos-bpos))}

        # Check if it is visual line mode
        if [[ $ZVM_MODE == $ZVM_MODE_VISUAL_LINE ]]; then
            if (( $epos < $#BUFFER )); then
                epos=$epos+1
            elif (( $bpos > 0 )); then
                bpos=$bpos-1
            fi
            CUTBUFFER=${CUTBUFFER}$'\n'
        fi
        #### CLIPBOARD ADDITIONS - begin
        printf "%s" $CUTBUFFER | clipcopy
        #### CLIPBOARD ADDITIONS - end

        BUFFER="${BUFFER:0:$bpos}${cutbuf}${BUFFER:$epos}"
        CURSOR=$cpos
    }

    # Duplicated from source ZVM, but added clipboard support.
    function zvm_vi_put_after() {
        a="$a p"
        local head= foot=
        local content=${CUTBUFFER}
        local offset=1
        #### CLIPBOARD ADDITIONS - begin
        content="$(clippaste)"
        #### CLIPBOARD ADDITIONS - end

        if [[ ${content: -1} == $'\n' ]]; then
            local pos=${CURSOR}

            # Find the end of current line
            for ((; $pos<$#BUFFER; pos++)); do
                if [[ ${BUFFER:$pos:1} == $'\n' ]]; then
                    pos=$pos+1
                    break
                fi
            done

            # Special handling if cursor at an empty line
            if zvm_is_empty_line; then
                head=${BUFFER:0:$pos}
                foot=${BUFFER:$pos}
            else
                head=${BUFFER:0:$pos}
                foot=${BUFFER:$pos}
                if [[ $pos == $#BUFFER ]]; then
                    content=$'\n'${content:0:-1}
                    pos=$pos+1
                fi
            fi

            offset=0
            BUFFER="${head}${content}${foot}"
            CURSOR=$pos
        else
            # Special handling if cursor at an empty line
            if zvm_is_empty_line; then
                head="${BUFFER:0:$((CURSOR-1))}"
                foot="${BUFFER:$CURSOR}"
            else
                head="${BUFFER:0:$CURSOR}"
                foot="${BUFFER:$((CURSOR+1))}"
            fi

            BUFFER="${head}${BUFFER:$CURSOR:1}${content}${foot}"
            CURSOR=$CURSOR+$#content
        fi

        # Reresh display and highlight buffer
        zvm_highlight clear
        zvm_highlight custom $(($#head+$offset)) $(($#head+$#content+$offset))
    }

    # Duplicated from source ZVM, but added clipboard support.
    # Put cutbuffer before the cursor
    function zvm_vi_put_before() {
        b="$b P"
        local head= foot=
        local content=${CUTBUFFER}
        #### CLIPBOARD ADDITIONS - begin
        content="$(clippaste)"
        #### CLIPBOARD ADDITIONS - end

        if [[ ${content: -1} == $'\n' ]]; then
            local pos=$CURSOR

            # Find the beginning of current line
            for ((; $pos>0; pos--)); do
                if [[ "${BUFFER:$pos:1}" == $'\n' ]]; then
                    pos=$pos+1
                    break
                fi
            done

            # Check if it is an empty line
            if zvm_is_empty_line; then
                head=${BUFFER:0:$((pos-1))}
                foot=$'\n'${BUFFER:$pos}
                pos=$((pos-1))
            else
                head=${BUFFER:0:$pos}
                foot=${BUFFER:$pos}
            fi

            BUFFER="${head}${content}${foot}"
            CURSOR=$pos
        else
            head="${BUFFER:0:$CURSOR}"
            foot="${BUFFER:$((CURSOR+1))}"
            BUFFER="${head}${content}${BUFFER:$CURSOR:1}${foot}"
            CURSOR=$CURSOR+$#content
            CURSOR=$((CURSOR-1))
        fi

        # Reresh display and highlight buffer
        zvm_highlight clear
        zvm_highlight custom $#head $(($#head+$#content))
    }
fi

