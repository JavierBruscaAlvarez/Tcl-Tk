#!/usr/bin/wish


##############################################################################
#
# PROJECT: EJERCICIOS DE PRACTICA
#
# PROGRAM: practica_jbrusca.tcl
# VERSION: 1.0
# DATE: 28/08/2024
#
# AUTHOR: JAVIER BRUSCA ALVAREZ (jbrusca)
#
##############################################################################

lappend auto_path .

wm title . "Welcome to Fruit Store"

label .label1 -text " Welcome! " -padx 0
pack .label1 -side top

set window .frame
global window

p_frame $window left
p_subframe $window.text left

canvas $window.imagen -height 100 -width 460
image create photo indra -file flag.gif
$window.imagen create image 231 50 -image indra

pack $window.imagen


# un entry en el lado izquierdo del multiple selector
# p_new_entry $window.text "Fruit : " 10 value text $window.text_entry left 
# setTooltip $window.text "Select a Fruit."
# focus $window.text 

# si quisiera tener dos entrys
# p_subframe $window.text2 left
# p_new_entry $window.text2 "Fruit : " 3 $window.text2 text2 $window.text2_entry left 

p_subframe $window.button right
p_new_button $window.button.run1 "Delete" [ list P_CLEAN_ALL_LIST $window.multiple.list.busy.frame.id ] 
pack $window.button.run1 -side top -padx 10 -pady 10


#   no se porque no me va en el entry 
bind $window.text <KeyRelease> {
    # puts ola
    highlightListboxItem
}


#   Creación del subframe y llamada a la doble lista
p_subframe $window.multiple top
p_ed_double_list_multiple_selection $window.multiple  "Fresh Fruits:" "Choose whatever you want" "Fruits" 10
pack $window.multiple

#   Definición del array de frutas
array set fruits {
    1 "Apple"
    2 "Banana"
    3 "Orange"
    4 "Strawberry"
    5 "Grape"
    6 "Melon"
    7 "Mango"
    8 "Kiwi"
    9 "Papaya"
    10 "Pineapple"
}

#   Iteración sobre el array de frutas para agregarlas a la lista multiple 
#   free -> unselected    busy -> selected
foreach key [array names fruits] {
    set fruit_value $fruits($key)
    if {[string length $fruit_value] > 0} {
        $window.multiple.list.free.frame.id insert end $fruit_value
    }
}

#   Lista para los ocupados
# foreach fruit [array names fruits] {
#    set fruit_value $fruits($fruit)
#    if {[string length $fruit_value] > 0} {
#        $window.multiple.list.busy.frame.id insert end $fruit_value
#    }
#}

#   boton insertado en el subframe anterior para que salgan juntos
p_new_button $window.button.run2 "Buy" P_SELECT_FRUITS
pack $window.button.run2 



##############################################################################
#
# First button to buy all selected fruits
#
proc P_SELECT_FRUITS { } {
    global fruits
    global window

    set itemCount [$window.multiple.list.busy.frame.id size]
    
    if { $itemCount == 0 } {
            set finishWindowError [toplevel .finishWindowError]

            label $finishWindowError.label1 -text "Nothing selected"
            pack $finishWindowError.label1        

            p_new_button $finishWindowError.close "Error" "destroy $finishWindowError"
            pack $finishWindowError.close -padx 20 -pady 20
            bell

    } else {

        array set buy_fruits {}

        for {set i 0} {$i < $itemCount} {incr i} {
            set fruit_value [$window.multiple.list.busy.frame.id get $i]
            
            foreach key [array names fruits] {
                if {$fruits($key) eq $fruit_value} {
                    # puts "Clave: $key, Fruta: $fruit_value"
                    set buy_fruits($key) $fruit_value
                    break
                }
            }
        }

        #   comprobar que el array se esta completando correctamente con las frutas seleccionadas
        # foreach key [array names buy_fruits] {
        #       set value $buy_fruits($key)
        #       puts "Clave:  $key , Fruta: $value"
        #  }

        destroy $window
        destroy .label1

        wm geometry . 700x300
        wm title . "Checkout"

        label .label2 -text " Choose one fruit and tell me how much do you want " -padx 0
        pack .label2 -side top
        
        p_frame $window left
        p_subframe $window.combobox top

        #   Crea un combobox
        combobox $window.combobox.combo1 -textvariable comboValue -bg lightgreen
        pack $window.combobox.combo1 -padx 20 -pady 20
        
        
        foreach key [ array name buy_fruits ] {
            combobox_add $window.combobox.combo1 $buy_fruits($key)
        }

        p_subframe $window.cantidad top
        p_new_entry $window.cantidad "How much? : " 10 cantidadValue cantidad $window.cantidad_entry top 

        set fruitsCount [array size buy_fruits]
        p_new_button $window.cantidad.run1 "Buy" [list P_SELECT_AMOUNT $fruitsCount ] 
        pack $window.cantidad.run1 -side top -padx 20 -pady 20

        array set finalValues []
    }

}
##############################################################################

##############################################################################
#
# Second button to select the amount of each fruit
#

proc P_SELECT_AMOUNT { fruitsCount } {
    global comboValue
    global cantidadValue
    global finalValues
    global window

    if { [string is double $cantidadValue(cantidad) ]} {
        set cantidad $cantidadValue(cantidad)    
    } else {
        bell
        return
    }
    set totalprices [ array size finalValues ] 
    set totalprices [format "%.2f" [ expr $totalprices + 1 ]]

    # puts "Comobovalue $comboValue" 
    # puts "Cantida $cantidad" 
    # puts "Frutis count $fruitsCount" 
    # puts "Total prices $totalprices"

    if { $comboValue == "" || $cantidad == ""} {
        bell
        return
    }

    if { $totalprices <= $fruitsCount  } {

        set prices {
            "Apple" 2.0
            "Banana" 1.5
            "Orange" 1.8
            "Strawberry" 2.5
            "Grape" 3.0
            "Melon" 3.5
            "Mango" 2.8
            "Kiwi" 2.2
            "Papaya" 3.0
            "Pineapple" 3.5
        }


        if { [ dict exists $prices $comboValue] } { 
            set price [ dict get $prices $comboValue]
        } else {
            bell 
            return
        }

        set total [format "%.2f" [expr $price * $cantidad]]
        # puts "Total : $price * $cantidad = $total"

        if {[info exists finalValues($comboValue)]} {
            set finishWindowError [toplevel .finishWindowError]

            label $finishWindowError.label1 -text "Allready selected"
            pack $finishWindowError.label1        

            p_new_button $finishWindowError.close "Error" "destroy $finishWindowError"
            pack $finishWindowError.close -padx 20 -pady 20
            bell
            return
        } else {

            label $window.cantidad.text -text "Success! Next one" -background lightgreen
            pack $window.cantidad.text

            after 1500 {
                destroy $window.cantidad.text
            }

            set finalValues($comboValue) $total
        }
    } 
    
    
    if { $fruitsCount <= $totalprices} {
        set total 0
        foreach key [ array name finalValues ] {
            # puts $finalValues($key)
            set total [format "%.2f" [ expr $finalValues($key) + $total ]]
        }
        # puts $total

            
        destroy $window
        destroy .label2

        wm geometry . 700x300
        wm title . " Confirmation "
        
        label .label3 -text " It will be $total Euros thank you! " -padx 0
        pack .label3 -side top

 
        p_frame $window top
        p_subframe $window.total top
        p_new_entry $window.total "Your money: " 10 cantidadUserFinal cantidadUser $window.total_entry top

        p_new_button $window.total.buttonpay "Pay" [list P_FINISH_PAYMENT $total]
        pack $window.total.buttonpay -padx 20 -pady 20

    }


        
}
##############################################################################

##############################################################################
#
# Third and last button to accept the total payment
#
proc P_FINISH_PAYMENT { total } {
    global cantidadUserFinal
    global window
    
    if { [string is double $cantidadUserFinal(cantidadUser) ]} {
        set pay $cantidadUserFinal(cantidadUser)    
    } else {
        bell
        return
    }


    if { $pay < $total } {
        set finishWindowError [toplevel .finishWindowError]

        label $finishWindowError.label1 -text "Dont play with me"
        pack $finishWindowError.label1        

        p_new_button $finishWindowError.close "Error" "destroy $finishWindowError"
        pack $finishWindowError.close -padx 20 -pady 20
        bell
 
    } else {
              
        destroy $window
        destroy .label3

        wm geometry . 700x300
        wm title . " Confirmation "

        set dif [format "%.2f" [expr $pay - $total ] ]

        label .label3 -text " Here you have $dif " -pady 10
        pack .label3        

        p_frame $window top
        p_subframe $window.total top
        
        p_new_button $window.total.close " Bye! " "destroy ." 
        pack $window.total.close 

    }
}
##############################################################################


##############################################################################
#
# Procedure to clean all selected fruits
#
proc P_CLEAN_ALL_LIST {list} {
    $list delete 0 end
}
################################################################################
