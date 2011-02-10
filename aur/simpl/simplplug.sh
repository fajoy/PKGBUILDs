#=======================================================
#
# the SIMPL - Self Extracting Archive 
#
#=======================================================

SIMPLVER=3.3.4

MYPWD=`pwd`
if [ $MYPWD != '/tmp' ]
then
	echo "==================================================="
	echo " This script needs to be run from /tmp."
	echo ""
	echo " Please copy it there and rerun from /tmp."
	echo ""
	echo "==================================================="
	exit
fi

echo "==================================================="
echo ""
echo "           SIMPL Self Extracting Archive"
echo ""
echo " This archive will be safely installed entirely in"
echo " /tmp. With the option to permanently install SIMPL"
echo " into a directory of your choosing."
echo ""
echo " You can examine this installer script with any text"
echo " editor. Nothing is hidden.  The gzip'd tarballs at"
echo " the end of this file are all individually available"
echo " from the SIMPL project website at"
echo " http://www.icanprogram.com/simpl"
echo ""
echo " As with all open source software we offer this script"
echo " without warranty or implied liabilities."
echo ""
echo "==================================================="
echo ""
echo -n "I accept these terms [y/n] "
read ans
if [ $ans == 'n' ]
then
	exit
fi

#
# SKIP denotes the line number where the tarball begins.
#
SKIP=`awk '/^__TARBALL_FOLLOWS__/ { print NR + 1; exit 0; }' $0`
THIS=`pwd`/$0


echo ""
echo "==================================================="
echo ""
echo " STAGE 1: Setting up work area in /tmp."
echo ""
echo " This SIMPL install will be compiled and run from "
echo " /tmp."
echo " Several files and subdirectories will be created"
echo " including:"
echo " /tmp/simpl.config - working config file"
echo " /tmp/simplfifo - working SIMPL sandbox"
echo " /tmp/simpl - SIMPL tree"
echo " /tmp/simpl/simplBook - sample code tree"
echo ""
echo "==================================================="
echo ""
echo "******* Press Enter to continue ********"
read ans
echo ""

#
#  Create the contents of the temporary config file.
#  This will be appended to more lines to form the cut and paste
#  insert for the users startup profile should they elect to 
#  make a permanent installation.
#
TMP_CONFIG=/tmp/simpl.config

echo "if [ -z \$FIFO_PATH ]" > $TMP_CONFIG
echo "then" >> $TMP_CONFIG
echo "	if [ ! -d /tmp/simplfifo ]" >> $TMP_CONFIG
echo "	then" >> $TMP_CONFIG
echo "		mkdir /tmp/simplfifo" >> $TMP_CONFIG
echo "		chmod a+rw /tmp/simplfifo" >> $TMP_CONFIG
echo "	fi" >> $TMP_CONFIG
echo "	export FIFO_PATH=/tmp/simplfifo" >> $TMP_CONFIG
echo "fi" >> $TMP_CONFIG
echo "export PATH=\$PATH:\$SIMPL_HOME/bin:\$SIMPL_HOME/scripts:." >> $TMP_CONFIG
echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:\$SIMPL_HOME/lib" >> $TMP_CONFIG

#
#  Create the working directories in /tmp.
#
if [ ! -d /tmp/simplfifo ]
then
	mkdir /tmp/simplfifo
	chmod a+rw /tmp/simplfifo
fi
export FIFO_PATH=/tmp/simplfifo

if [ -h /tmp/simpl ]
then
	cd /tmp
	rm simpl 
fi
ln -s simpl-$SIMPLVER simpl 

export SIMPL_HOME=/tmp/simpl

export PATH=$PATH:$SIMPL_HOME/bin:$SIMPL_HOME/scripts:.

export TEST_HOME=$SIMPL_HOME

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/tmp/simpl/lib

#
#  Display the relevant temporary SIMPL environment variables
#
echo " temporary SIMPL environment variables"
echo ""
echo "FIFO_PATH=$FIFO_PATH"
echo "SIMPL_HOME=$SIMPL_HOME"
echo "TEST_HOME=$TEST_HOME"
echo "PATH=$PATH"
echo ""
echo "Code will be temporarily installed at $SIMPL_HOME"
echo ""
echo "******* Press Enter to continue ********"
read ans
echo ""

echo ""
echo "==================================================="
echo ""
echo " STAGE 2: Undoing the installation tarballs."
echo ""
echo " Several SIMPL tarballs are extracted into /tmp. "
echo " These include:"
echo " simpl-$SIMPLVER.tar.gz - main SIMPL source tarball."
echo " simpltest.tar.gz - SIMPL testing framework."
echo ""
echo "==================================================="
echo ""
echo "******* Press Enter to continue ********"
read ans
echo ""

#
#  Actual undoing of the self extracting archive occurs here
#
cd /tmp
pwd
tail -n +$SKIP $THIS | tar -xv

tar -zxvf /tmp/simplplugbin-$SIMPLVER.tar.gz
tar -zxvf /tmp/simpltest.tar.gz

cd /tmp/simpl/lib
ln -s libsimpl.so libsimpl.so.1
ln -s libsimpllog.so libsimpllog.so.1
ln -s libsimplmisc.so libsimplmisc.so.1

echo ""
echo "******* Press Enter to continue ********"
read ans
echo ""

cd /tmp

echo ""
echo "==================================================="
echo ""
echo " STAGE 3: Running the tests."
echo ""
echo " The testing framework associated with the sample "
echo " code for the book will be exercised next."
echo ""
echo "==================================================="
echo ""
echo "******* Press Enter to continue ********"
read ans
echo ""

count=3
while [ $count -gt 0 ]
do
	echo ""
	echo "==================================================="
	echo " List of Tests "
	echo " (You will be allowed $count more test runs.)" 
	echo ""

	seetest i
	echo ""
	echo -n "Which test do you wish to run? (suggest s0001) [q to exit] "
	read ans
	if [ $ans == 'q' ] 
	then
		break
	else
		echo ""
		pretest $ans
		dotest $ans $1
	fi
	let count=count-1
done

echo ""
echo "==================================================="
echo ""
echo " STAGE 4: Allowing this SIMPL installation"
echo "          to become permanent."
echo ""
echo " You will be asked to select a permanent directory "
echo " home for this SIMPL instance.    Once done the"
echo " contents of the /tmp/simpl tree will be moved to "
echo " this permanent home."
echo ""
echo " To make the new environment variables permanent" 
echo " you will have to cut and paste the contents of a"
echo " premade config file into your startup profile."
echo ""
echo "==================================================="
echo ""
echo "******* Press Enter to continue ********"
read ans
echo ""

echo -n "Would you like to install this instance of SIMPL permanently? [y/n] "
read ans
if [ $ans == 'y' ]
then
	count=3
	while [ $count -gt 0 ]
	do
		echo -n "Where would you like SIMPL installed? [eg. /home] "
		read ans

#
# Intercept a null entry and allow retry
#
		if [ ${#ans} == 0 ]
		then
			echo "Invalid entry. Please reenter a valid directory." 
		else
#
# Intercept a basename of simpl which will result in simpl/simpl
#
			MYSIMPL_DIR=$ans
			MYBASE=`basename $ans`
			if [ $MYBASE == "simpl" ]
			then
				echo "Please reenter a directory which doesn't end in simpl."
			else 
			
#
# Intercept existing simpl directory to prevent accidental overwrite
#
			if [ -d $MYSIMPL_DIR/simpl ]
			then
				echo "Cannot install here."
				echo "$MYSIMPL_DIR/simpl already exists."
				echo "Please reenter another directory."
			else
				break
			fi
			fi
		fi

		let count=count-1
		echo "You have $count tries left."
	done

#
#  check if all retries were used up.  If so exit.
#
	if [ $count -eq 0 ]
	then
		exit
	fi

	echo "MYSIMPL_DIR=$MYSIMPL_DIR"

#
#  The directory entered must itself exist.  Allow the user 
#  an opportunity to create it.
#
	let count=3
	while [ ! -d $MYSIMPL_DIR ]
	do
		echo "Please make sure"
		echo " $MYSIMPL_DIR"
		echo "exists."

		echo "Hit Enter to continue once you've completed this."
		read ans
		let count=count-1
		echo "You have $count tries left."
		if [ $count -eq 0 ] 
		then
			break
		fi
	done

#
#  If all conditions are met move the simpl tree to new location.   
#
	if [ -d $MYSIMPL_DIR ]
	then
		mv /tmp/simpl-$SIMPLVER $MYSIMPL_DIR
		cd $MYSIMPL_DIR
		ln -s simpl-$SIMPLVER simpl
		export SIMPL_HOME=$MYSIMPL_DIR/simpl
		SIMPL_CONFIG=$SIMPL_HOME/simpl.config

#
#  Create the startup profile insert.   User must cut and paste
#  this insert manually into the .profile or .bash_profile file.
#
		echo "#=====================================================" > $SIMPL_CONFIG
		echo "#" >> $SIMPL_CONFIG
		echo "# Append this to the end of your startup profile" >> $SIMPL_CONFIG
		echo "# in order that SIMPL environment variables are available" >> $SIMPL_CONFIG
		echo "# at each console." >> $SIMPL_CONFIG
		echo "#" >> $SIMPL_CONFIG
		echo "#=====================================================" >> $SIMPL_CONFIG
		echo "" >> $SIMPL_CONFIG

		echo "export SIMPL_HOME=$SIMPL_HOME" >> $SIMPL_CONFIG
		cat $TMP_CONFIG >> $SIMPL_CONFIG

#
#  Announce this to the user.
#

		echo ""
		echo "=============================================================="
		echo "Please manually append the contents of"
		echo "   $SIMPL_CONFIG"
		echo "to your startup profile (.profile or .bash_profile or .bashrc)."
		echo "=============================================================="
	fi
fi

exit 0
__TARBALL_FOLLOWS__
simplplugbin-3.3.4.tar.gz                                                                           0000644 0001750 0000144 00000250445 11345467366 014067  0                                                                                                    ustar   bob                             users                                                                                                                                                                                                                  � �n�K �[moG����_�X^P�HY�Y�=@��D���{��!h�4�Y
8~Aڧ�۬�ӠU��4��j/�%Yl�j�j����Qm/���(�H�L��p-��,�ͭ)J�$uj�rt<��{sc��XId��H6D��Owsk�Hٲ���\۬[�J:��q<X��̯����1-&��d�ꅩ�_�W8Ap���P�yKp�%;�$��E�)!�$���Q�b�m�<Z:��wv�uf䅛5�@�tf-+�lF<Q�v�n%���"��SUT�vmj�*Ć��?&A Z��n��Nk�`ގ�,��%9��'���M�c��zx(�p�p�e��P���
�ɉz��T���� �_,�	���&C�Lׇ'�
��h:8a'k�'�J�b�?�I�.�l� E������'��F�ݹ�F��-���wo��7w ]K�3K�Q1��� м� �9����CZ��=��D��kjO:F��6E�8k��pP���tzgE�sG�
Iaf�)rY��$��w����ӯ��t~�=�\�������	��/�'��������Ç�������g������g���O�_^��
��������zh��x2���nQN^�~M��
���4���*��2�
g�
��F1H6���䔄��t0w��Ql�9�8:�����v!?i��7��jJ����� ��˸=�2��lAvF߆��6cB�4�A�o�P�D�
��0���*T���X��Y�h��ɝJ��"M ��k���&H�;�i��n�~"� h��$x(&�s�Wj�6KG��n��DVHM1�:aa,,�˾�|0N�R�!�\�y���a��b'5�'i�``���D�ن��I��]l��`#�aY[R��D9crU@�TLV�,y��/@
o���"6
Z�Q����X�$�/��x!Ӈ6�Y�3��h���Zc
�8N���%P���z)1��E�C�K�
�͸��ݓ�y�xI�,�ƔP��v�}��7�fN\!��U��mځ��Jq=��Hܱ�
� �$�Oy��Sh���U������_څ)C#/��F}S�u9�y��������=Gd���7i'4R�e��j���'��Mh�J�L����;C_3d�LZ�&Ά, �-�/*/%e��M>�:@5J�=��� �$��(�50��VI�}�QN�����nfD�%k��X��2+�'խmj���b�[y��ͨ�c��* $�$D� A�n��~��
-)L!"�e��z ���{06B02�ՙ��$<˨No����	��+)K�����FTP�eB#��G'�1-	v[;
{�Q�W�) �la �(�͊;C��:��v�Bn�qMȄ�Fr�Gd�R�:z u#��B���m��@�1K�`f�*�E�ˑy�%ur�@pb;$�!���i�ԗ�B.�8H���W��Ҙ�Ux�!;�̋w�n��1�A9�dMdq�J)�n���Wh�6=á��[ H�\pRYc_Wߐ I�u��r�|1��uݓ�#ړ>�)�3�(+W! 骨���1��tZ&�J2�@��TQ[��M� �4��BPk�b���vN������3	��{��3�)G7�1�-&d�k��LS��i�ꁵ��:�	���g(n�x����\~K���2i[".Z>zh�;R"L��2uD\�;�N� ���$.�)�uB[����/T�QЉ�n{�_��X|ꬨ�v���Y�r�5�v^���p�#5�2
 ��1#cBqpa��:�`��06l�LZ :����Ej8��=\�3� �Q�[9D=~���ɾ��󦙿�x�,�备#��s
�l��Z�";��*1��p�|U���$��ںui�5Kԭz��
SFb&�����eQ��:�S2��zVR�j˧� �s1�K�Qӳ�Fp 67��/�8����'��U?�1%A\��8�AR*�p��L���� ߸���� �v���qt4�jnX�*/�S+�d��-��ٳx0
%��dP0�m�ЂQ4��d�3����QrR5h
�cr�Ys����q��j�M�:��#+�耔
�+(��!x�c�.L%}�N`�}k�A�&Y�@�Q�4բ%HDb����!=4�Fi	�@�<��K���:��J&������"��U���%0�/�m$N��-�*Fs�~eh}
�P�o&�����ҷu� �,i
���y��F(a(�}�(�)R�WR�oက]gϻ!��p��G2iE�fRk��l����\�I�^���{K��%�C�e�Q��l'R��� ���rQ%wڃQ�+�E-`�C�}�$��q�EVm2nb�Nb��CY	�	ዑ|U�� ����!9g����.&�x�2�1�g5�y�z��X�߰���E�"孻A�i0b38�3z�a	_��9���R�:�e�1�-�C��EJc��ɤ��h@��@�<t��X�	�1V r+��3���c�ڮ�Rb!˛�e����'�Sg�^W�����o8G��J�d']Zb����H��.2���䪥�,�Lq�KK�ƎU�ٞ|�̦oeb_��"VI���e��!���4�}IoEh��8x	�d�rP�.��^��v�Jn�^<$�a��!��a�* Ez��)OřO���������g�EK��$ �zKc��Z����+������G
�SX"��R󝱎O��$�����.��5�O�U����o�����3�C	Ͽ0x�B��ch�5B�5f���;}v����"
�R���a�q�+�>r�6��Z�9P�pa��ah�-��P|��&�z���e�H֤�}n�ջ7¸�3�K����D�K�t�>c<�&--c�>l�U���������>�U^���{o�KZCE�Z�
��n� ��5)L�4	�Nf�
�s�Ym�7C�^��Tb�CDD����byy5
�P ��jlW�����N�I�����	��	Ơٰ�i�v�p�S3s��3�:�b�KodHGbs̪Q�7������w(��g�x=�yt���M�^^�+�Z�N(�A�s���m��).��k9�A���,\��w(i�菷�Mo�y����=IO���RNx�Ǒ�MO�@�x��ߔ�h��n��u�9'���7�B^�I�Y07�I%[�t��G�r�g݉T�z�a�D��5W�'bB����j�<`!��O}LC7$(d�Ҭ�;�]s�$o��ܠ9i̿���Ƚ%0m�'����Ϲ��,��bS��`�8Q��Τ�.�ً�L�#"ޓ�����^���f;5�BS4&pt�߮g��K뫳hu��7ِ�h�[O���4e��w��h�nŅ�ު���nl�ppǗE{�@�'��ʕ�@$:�)GcSw<a|h�
�E��$�m�ԦB�T �\�l���7Z,v�pDe4A�y��p{1����ѧ&}��^k��� 1��:s	G=]�l+��1����|>�Y"�%�l���|��
R
�O
*���A��9{�0�E��t,|�Ǹ�avw�^��5�<�lU,F)"�ŎH�2GuJ�A�Y�5La8p���:�1�P[1ʴ�@B���U4��e"Xa��I)�U^s�7gƗ/�
`$[p�wB�R	C&zڸ����C!��t�w�jdX��x���Xw���A���QpF`,�gӛw�I���A3�D�ZX�)��sL�[�$��|G����]N����ːI��Ëz(m-�9��"�*B�q�Q�����r2%R&��l�TL o�\��1
Q\��:1���W���r��t����fANͻ)�����|MC� �n��z(uʨI$Yv�[�_�����X'�i d2�9�X�eP����	.V��^��cUH�c7 ��'/sQ�J"��l-ĸ�K�N$����E«��NE��3���T�5��-��n3��ə����!�����QO.�u�.���|kr�PcJ������^��{Dj~����2�?u ���?"��\'�/��� ��rw�Qe�e�+��Dv4~B�ztК�&�<��)��cݝ�vن�����9D��M�uA�e�K���$��Ie���LXe�g�����1�ۚ�ZY�H�1�~�JX(�Dm���T�rv�+5�hMA�R{�%#|��@a�w
\��8׸/3�o#���3��>zTu2��+3��[+�,�+��g�z����``�Z�aс���v��Mu}�Ȝ)#1T�0l��
���X��`,;<҉�(Ef�QpCHzB1͍+�Iu^��A���������"δ� �-/i����0@u'�Pm��Ɣ s:�R%>�z212E�l��8�J��>Q�G����I��L�>���(+�q�(w�G`����"�_��I�Z���t?�ӼN�r|����aD�H[g6?1��EZ�}���<d]]���@�h���7�G�N��UU�n����Y�k7H���2ʸw�K_��,~��g5�&:���Q�m��-%�
��a
�
��z��*�k�*	:�岩?��^Eq��~��lT-IM�CEG��P��!�G�
{9a@I�@�Z�fLC���tL�
"Cb�����I��+_����@�%�K_i�NF��4���nf}�<|�H)�q��eu�F�豫Q�	MS����s.T�-)д�r5�"�S�㩃&��*�� �ԝi�}�����
z�Q�o���ຸ:�h��}�@���=�� `�tO/I����Ž�<�9Ԗސ5���'�v}�p���������T]dN�{��+������ꥷ�V���.�����%���+��++jo[����c����K�e��ʾxU����n���eK��)�[�t+jj(�[��{��ū.��w�\��]���XJ٩�������;j��/]~����Ko��w+WT/Z\�`;f�����nMEm���unM튏.]d�izE�z�{����+�z@�*���Z�|Q��x��h�Z��,r�`PT�t19.]��z�"�r+Ű|E=�N#o�+T�Dį�����-���[^_q��꥔$ D�,�_NI�����/\Y]Q�YY[��n1�=�A���vi]�K%�z�}e�U.ű�b�B�Nȅю(�{犕8��rW/�*��]�x���K?J�K>)����G����UUW��/��"T��ڏ.]��vqM��ZW����"��y��[�ƣ����+����߾�ʓ�# ��ۨ��2)hD��K)qj����WA��o�;��p�U��-wF�{P����+�J��Yq�
���pV٢�P�D�D�*�Uܶ���*iA��w�j/\
�Sף����E��At�J�"}�H�
jNĀ~�M�b��-�}�Җa�5g��vj�s�Wԩζ����U9�����w�v�r�/5�*.\YKC>�rS������(� j0/�]�'�sdI��ꕵ��y5H)��*D����
8����0��eJ��+�NCiW���R�lq�idIeF�S�����Q��[(�E����
0��A���Mލ3��1m>[��{h��ti5x?�岄%���ɽ���Wx��

}�V8�D��� 7����k�<P�Mc+n}h�EM��2��¾KS�5�q�'�/�3Z�+��6�}�h�"G3�>�P����VG�u��	�щ]aBj ������=�kF~��
��z3~�b꾑uC����q�
�5A�����Hʵ3j� ����M}N��3X^�מ�e�Q/����')?
�8��Tw�/�'3���t�c����Y���0
���_T��,(�����u?o�li��jV���j�9XQ����X�p�G[�.�.Q;�$+Q�YL��
-�A���@"ƨ	޵���Z\Ґ�V \��?�����6�)�Z-��K��T�����8MHy�
:�h��[�"\�
QW��T�5�WR����k�V�#��3���uwܿf���D��Y���ۥ���4���>z� ��yg@���<���h�*�d,�H��Qը�LH�B�𲦯$$6tƻ8!�0[0��윅|?.������ٳ%wM���n��-��ɛ"�?U}��3��q��^��j�
ɯY�Z<R����
� �D�hOH�R�\�Z5�8� N��ĆXww�R���y����>�Eȏh�Zp�DҸ��/��B��b�$�mX� y7��Q��f���[�WZ��IS�!E��
U��h�l\��)e��(��J޳�D����ǁW�[�	�[�|����w#���y�D�Z$���J���\6yL�@B��Sl�H[��3{�	�	�w�A�=J� �eπ)S�]�8��Ft�4����~�ui�P ��L`�0m4+:�5�/��� J_%_/����.Ij	�5%;�Ŀ��G�4g@YG��I������ M$*]qw!u�%�|�s))QJ8�
��ɞX��$�V�Љ�dZd�FV�k�����'G� B�����NӃw3���{�N�d'�4�����ob�.��cy9K4��D/�I�-�P�|S%ߡcR}�;��gz�� �C���:Qv���:Vݪ3�!�RWS���5B����i�f����M�r#-w�Z���7�ݍ���Nֽ�%r(j�Gjx}C~P����`~�'�ϰ�����kڠ����dh�۸�!��7߽��S���W7��@

Q��p��4	q.P�R;���o��Y���U��^��X�{�uǚ#z���So�(Ķ�H�\ðJ��(#���t���T�-U�֌�vC26�nUbY/�Z�)ta�J�4x������Ykےz9�u.c/Q�	u,S=�1�CN^0���:e��t�n(�
�j��Ļ�������F�N�:VN� (z�d�i�bh ��j�]��	7�_�h��	ٮo�K.�.g�*��|J"�����w�t���Ow��z�w��WM#)5zň⾈�8}ojm��6͚�4���5��G�v"�'�`�SVr�kR�4�'��ĉ�ɦ�ى��ˈ:S�HM�Z��-�eu�5��Y���IrO�h�i� ���᳠D�[���QP�\���u+kV�
�P�Қw ̩�̈́�9͞NO����#F��n��_���m���k�p[}%�f�-QD���f�Lj�s�6(V� �i
�v}5�CJ��a�N���+u	�m����\�."#48{Dcp���T�y�E�]F��d[{B�����M��&���R�?�9fy=i�,�Q\8gnP�c^tμ+�o����$ں�����:�ċ��(��3?��"�1LJu�I�(YPX�Ƌg�[G��mUfb�=�3'V�(*��R�cwX��*L�;o E9+=�\o��k��U:��ޮ� ;�wr�<
�l��*�G��7�Z�;�w+.�\5�ߌ2Iz��(Gէ�
s5�!�%����S{�	�����S���2YQ^�\ȫ�ey"������"�ӭ�YǼD��Lj��̤0�Mբ�d�s�ƈ}����:��|��AZ�D�?u��+b�yh��~����Wpt�*~V�����q O:�!�wnD�&Ja���'M4j1_�Y��<���J����aD�x�nA�X����%�d�V�eklB���NQ�\L�S]܈c�Y,�c5�%]H[��B#M`G�Q-��s��'�d�'����`1+�#y��r-[���ZG�1��QG�S�%��֭�ukQ9��z��������U2:�֘G4ӻ���P�Js�G�H����^.cӓ�`a#0��0֫��/m�N[�O,��M>y�t:y,��Z�X�ۺ����z�z�AS$�'XL�:�^x���h�]f[U\���uʑ`��B�*�<ڈ�n,}TНm��X�S�,%������hHȩ�6��w+~��I�Oj=F��M������.�FHtf�e��{:ٻ���ѴL�ڱ�H��*]
�>�hWd}�=��(�A2kݺ��OT�m�*�p�6y�B$�xUŲ����|�D�4&��sk�i�L�-��d�;[�7M�}z���V�A[�Mdh��wl��B�bO륒Z`�L��g,���b�J=밵�oN?M@=n�%�H���էmn���ڻ�拙>�k�/*(�[ZPXP-���
U�> �%̕�Х�ڋD�\wyXmV��lO5�f�>�7��%��#V�T�Θ�>8C��u����*Q�Mğ�� a���v6Ό�a�a��f{�܌�(@����j���%|�[�
\�)�D����Hi��Rf��A�K�Rn�]�tO-�<�yn�Jv�ƶ�
Z�#����*��X�i����`��j�[��i,F)�髡�)\,�$� ��N�8n�e���S�����`Uݖ%�#ZW�O=�XK� �殶F]�E(����Έ/o���CB~5�����r8�o=�Zj�/6o�N��v���fa��a�13�i���F��76����ah��Ӕ5M�oi�p�}���xZ�ѩ�s-��ښ��a%VH3���\~,\��rsTS5��h	��hܹ)���e7�*��e�_�GG����݂ GR��E
V}�K����#H�ݾ�N=�I�uj�@*������X�3ub�26	���I�@52��m��sW'��L���O�K�T�2��E��ZU��F.�!�r�Y">u@�'@$F�\z9�垦.%[]���h�qR��X�n}�άXܛ	 MI`s��S<\��+�$�Lu�;.ǆ�)=]{��H3�,Lz���# ����S9ï�hi�\�A[D�H�+j�+��Os�.�R�jw�ʺz�P3/�q�U�e�%�{͂"w�$$P�y}@-�o��XZˍ��+@���e��Vg���VL0��=�&>E-i6<\�*�R�pyv��X{���x����2�9�

6������J�)�v	���l�#qf���˾���)��}B#l(�V��v�JJ
0z��(�r�7��Q5����Jc�����s�J���z3~����f�P��(�Xᘀ�6T�zj�j*ՅYܤXV��]Q�����@���R�-(�����la:v�}nuI�( -u�Ƀ�e}u
�W���gu�%�TxP�Ms�y���z��˻��iĕ�Kl�8j/*7J߀�bD1q�QU�X���I�u5�v�;�):�{l�����8���dCC:m ��1it;�M��a%�^��R;�(�m�X���1��+T����v�U����p��f�����qa_]d���1�G���P���¸���s ��U}t�DF��.VMݪ�"^��f��$>iv,�4��� /����:y���5��jл�Eƭ���U�ӵ���sQ�y
rv+�A���9�	���r|���2-m�z�����!�J!8�_wG�����P�'�.7FZz����ф�i\v`Tn�Y=`=0�c�O(^UR3g���N֖ܰ ��X*V��G�J�
嗯'y���
��s��E�9s�b�/.�r��M�A/Ƈf]�߇�����k��]���e�KK�[������Q�W���e������uݏ�&��S���%���Uw��j�Ñ�G/2OF=2$+G�����'2J	+M�O-s���4M	���k�8ҷ���F�/}�6�!j�4�F�ϛ`t��s7�͚u�F3���7Z�r���w��ϴ����U]�w��|��Gߐ���M�$i[i����&��~~o�6�Dj�@$c�ߥ��o������]�X�ϟu��&���sL��FJ��)����ģ����8�#�4�Z"�؝�9��}���9����.]$zi9�Qr���[��F2�:�cb������ѻ��A��I��LQÇ�f+�K���og��럭�)'}|c��R~o�l��>���=�,*K�����z#����┆̮]�p�ҏGh�u*
]��:��Q���Y�Z����C���2�]�/ݳRK�zR�����g��=<�$������
���	�\�!���Q�%��D&�V�����ᠧ�s���(��.(�K}9�V�
 ��/4~�Z��@ҊZǪ���M
6�Q��)�[�FT�؅ n��LAb���u��q�CŢ�0,Kg�@#��Ȅ���Ťf��
ӡ�&1�'�{���3H��͈�TZ�.��4����PĢb��&+,�7�I.��S��C��R|}"_臏���s�X�	���ӛ�Js�1:ݩ�B���2W�Pz�u �Ta��_QA���8%�;���K��RH8���@��D%��4�u5A#�:���KW��)d3Q�f�5�Z�L��?�Mm_\l�C���5K�MM�DD��EUpwhQ��i�G�4=�S-Q=��L�槚J�ՄmC���n[\|��]��B���������֢�ih�j�I��u�Xw�;}��ȧ5��Pq��
�J��OK
�鿢��+�ߛ�{��_�����3�2�u�*	RQ��vCD�)�d����B���W���)d!�tT���/
�<�l.���]m�
�+Q�E���.���qy4o��I�����ɠ�QgX����#�D��}Bs5�%�E���I���
�-W�V�7,�w���F��-,���(�ιB���7��K!0
Y���o+�м�Nt�tv�|���ր�9����&)J�
�(��BK�»q
?ǦXY���SA�+-J^��Dfc��~KF��`]PH'$��-L)	n*��%1[+zOǥ��,ŗ��C���K�)ļ�ogI��<f�VjD��:w��دR46-�@�<�I��TJ�YCaNB����ె\	U�P x��M�m��i��J����9�ӭ�U>jC�SgŸv*���2u�T{zL	b�VZt�}=��&g*�ՁS5�e����s`���F�b:�M�˼W�Xu��ZӖ1�κ�jH��L�*�p��RKjE�5�D�IHt�|���H����X�N�ޘ��"�p^r����5r�x{S�%_��I�a��Мs�x ��������V��
�t��+��� &�m�}�]�]�V�Z�e���Hc2ު�\��2�y.͟v�^xe�~e�~e��69�ymۋ�7F����1]��Gڼ.(�.h���W�F;�P�nL��#���{c`�Ð�/�E�x7�oecԿ��s�)U!J��x�ƽq��i}��#Mt��ӱ�&�4�x��oLw��5/A���˾�!�
wc��x5*h��@�=�7�*�O�c��H�\�g��Z�
�@�j���֥3�`uK�.>��:#1}s�I�i^t�%y-���1{/�넕���(]�F
i%As�Zj��>���&*�a��^7�w�C�Y2������A�����)|�����ڶ���=]5"VZ�;7� 
�s�U
+����TV��k�S>9�?ս�t^#�{�:z:d������3Y=ߢXKcO{�s�y���V��J�-�Lvop��|��A��b�Z��K��;�Hi%UI�w������4��N�_��j�֣lYۯ��7�[�s�����J�Ou|����ݶ�Ǵڔ{�V�>I�8M��+�1��0m	�4���l>���Ђ���CC�#���Ty=K�/mv.�W3��;��?���x��<"�opK
���yS��_��ő���ʚ��ˑ��6�=C�?�����M�_�w֏׫�٭���D{�]����x{S+QS
�w��nJ�PDɶ��7&-�D)a��V�ᨩ��v��M\�kT�Ak罉e�|�����_9>#뺬�Y���M��SU/��o�嫯����"�fT��H�Pq\]<�ݡٳgGg�
��c/㚐�,�`�o���!=�1G�l��|���_��Qp;d�WПF��	a쏫�]V�_�l�3>3+41tM�лB���
*n]:+ٸ�)hmL�:�:) ���N�I���Z�r뎵��ړ��vn�X/�U����ڈPn���)��6�t-��pҺ��k�'��U;ښ(�8�ƱО�)v�-��g�Q��ڊ�-�i����]��Qm�a�-"O�D���k�qSs��#�l���l�w����b������8������5���<��5��.O!�&�m���a��f��:�=���`�n��?��_�d>�N7,O��k6�X��dr9�t�kr��X��d��9]��
��"y�i����!gҌ�W�*��4Z��r��v�H_n�_����@H�I���G��4�7��s}��&]���t���G
��yGȨ��d�
����YP<��ԉ��̒\74,�����T^�q1�V��֊�K��-��-�a��l���Ew.�X�t�c�򩓻�r�HMN�h���ީ\�P��z�����m�
�͍���^��y3~�����M9���t���7Z��t"?����?���?�&�	��r���_�;���;�;��H��º	:>��O8�7��yBH?�~�]iٝ��1�<�5��0��
��J�AS�������f�K�9�E��*��ޭ�f�+��i����k$��S"4���{���D�����F�q �	�����
j��OKK{O�5��-��44�)������?�6d�B�'����{3�û2�=�Ѐ*���Ϣ��TFX��o�@�AS�75�*�i0����ϚH��O�0r?���Y���|��c���a>d��}�y�a�3�;΍M֧h��g5u�mD���26Y��Y���L��$�1r�>�y��a�c�\g�����L�Mq���u��o�
}Su�Ԟ�+���cUJ&%I�Υr�E>&�����gd����fWMHm����̂9�E���Y�5��}*��[z:�w����:�z���|���S�F�sQ���Wɺ.�S�l��d>^r��|�DX�kX:��~��@8S��P@��� �h�O/V�?�c�No��[,����y�R��@��$�Q)�'�\���"����Nޣ4E��������=0S�=2e~F��%:����_��Qp�7ܯ�{\��x��/�ɟ)��1�{`�>4y��������{T:#�{`씎A�C���]c��{��t��e�"z,kty��~�W�Ɵ)��TG�� �d����w]�4^�0�Ly�}ʇ�����{0?ktyІ%�g����౴F�׳)�}Lo��#�����7y���{@�e,��W�M�c�Uc��8v���=r�16y���16y�cD�y-��N��m~��{�=���8���E�C󺴼G�ggy��y�������=4oM�{�xv�٥�_��e���=�=;�(�<;�|%m�X�ggy�^�~y�{d�2�р�G��Gc��c�^����~x%?ѹ`���{:y��J/�Q��	#?��=t�iy��@�K��{�_��,�{�y�G���ey�U��W����(��cy�҉�,���	��"��G�Q�Ho[ �U�����I#<�7?h������.�>���b�?l؃����?� �c��y�?��:d�g��#d�ًB����!>��CV�C���B~�|Ȓ�}vqG�˧�Cօ�0Ft���]!�l�	�ú��v����}���}�q$��_ˇ�c�>�8���+d�ud���ȇ��ȋ�7l�M�3�Wˋ�	�W�������~C��'�ܟ�K|=a�l����������@���g#��F~�����w08+y�ʋh>����̏��H�e).�A�Qb#c��*;�7Cx���!��2�s9>��l�GR�?��/m��Υo����+��ޔ�p�;���w����!B�f+?o����l~L��R�����?Z����"��=�P��������q /�y�G�Ok���7�������v\Y�O�����pq$���I˩`��^'�������i�W�z����K�Q������!�E�JAG���g)|��	��.��y�?�rR�"����)r�0����w���U>]��K.�_#�M�*���ߧw>�����K��gST�����A�,zЧ���y��
{=���+�����ć���}:��v�CF��(O#���r̫����/�>�V�����n�ׂY�F>%(��Hv7um`@��Xcss[�CtdP�*��tA����X���HĔxJwwg�eR�W��5�t�ng�y�w9��x����sDcI�7�F�ބ<�/����W�KȩrRea�Ʉ����]4���b�֫X��*��麊e`�W1N/�4Ylě&�MW�L�f�i2�r��l��1r�]�22��	l�4�켊ef��	o7�4�����^��o�IT#S�����c`����y�a�b�7�^��e�[
?[�&����u��]�EMw�m
I��$J�H�藧G�����?�����t�˗�S)�T	�á�k#Nߩ	���G��h�$��ϧF0}6ҳ����<?F\����>y���(m�5��f���=;١�Vv�	 w�k�ﶴ��ݮ�d�,%���qy���-s�&��b�H�Ҟ�+n�_M��GF�v]~9��Y�ф�*4�ʗ}��s	�+d<X���~�J�:����M)`������,�"#UJ/#��*�����2R��g�������ϔ�z8 �4�_�wG�ֽ.�c�.Cܜc�oD��Hێ$G���0m��9����xZ9*�y[�
�����3�0S�PX��(��D��ǩ��S�'��0ܯ�Q�:f����º]J�]�$G�u�2���`�L9*��SD�馓���G�3���Ǎ��:��8�/F�����:~t9*�Ə�5�_P�
���8gG���X�2it9*����@����f�.G>٪ >L:9*�ߎ.G:p�0�L9*�;�������Q1_xt9*Џ��b^�_P�
|��W���2娰�>x��?ݟ�rT�79���&G����Q��X�v�M�*����Q��flrT�_369�\�P�����prT�.e��`�=��X9�ҀU�'ŽN�+��/��rT�{v��s���4�U�Q�yv�����h��s-G�ó���k9�U��g���
�焷��s�;!o&�!_���
�焑�tr����\l�����^0쐋E�1=�r��^|,���{Y.�	�\j��/ذ�<���c�X�Iz���@|������ݻ��Oܟ�/2�j�;���-�����7�����Oi�: �{x\�ӎ?^!����lO��z�ANk�����L
���%�9�J�%s�W���)���?K��p�C��?O\Ot�7�y��?�\Ϗ)���B�9M�o��?�]�'��[)�9�a���I�|������8�[ �"#�$�?��3�a^��.
r�؍a�>Y�`��5����3"����KW�4��4��=�$�l��,~��I�;H�|���;L�M��+o�(�լ�����رcE�݋~��ƌ�an�������4�=d<�0߻F}=J���w����a�FΤ�[R��މ�}�r�Y��=�?s�a����C�E��}	�[f6����{�{�(
�A�_&�*��٫
��mF���v�?���e�������T��S;��h;�l�����Y�ϵ��vg����s9�F�ԩ�����$I�$�����,�M���h�Y*�6�s���6Jcl�ԋ�7"���wc>A�S���#�k�h��F�T�͘�ˌ��\k����J���⏳���2�iѠT�ՠ?�L����U�f��Z�)?����䛢٤Mn��pGl��X�L��ӏ2��Ի��>�a��ʴ��e ~��5��f�c��Ln`�d�:�/]�����Q;�����;���&�vOt��w���&m�������rL�r����	k�I�,MZ�<?�����<;m��� 8j�
ڂ���>G[�g�P��at,����X�"��K��_��4�C�9t� �l�����N����ëz��4�µ\0t6H}�#�dp�A;ѷ<r��ӑG�z��>�mU�Y{
�w5�}
nR�%4���<����_��:}� ����ź;��RX]����b�<�b��6D��2»�G(�K��~���2g�_S�<��w���{)n��1�/�(�^n�����ib��m��g���G�N��;X����˾�j�S�~��Ծ"#]��6#����FZX����FB�[]d���J��^���MY�����v�@��yϧzU�A(�{dnϤ���L����H����@>�%�
��tK����}�e���N�k-��g�^ݞ\l�齔��B{ܔ��)~�4P\�i�m?����Q�Ǣc(��`�S{�'�5�/��?�q0j�4�p���(?�;�	:�T?�q7A��.�c�}���^o�˼_�w��� �5C�W֧��>����E��e=��96F�/�������W�>5����Z1�A
�G���:ׁ���jklo�T��r�xz^�wc�-���g��%֬�����=���h^��{>�y�7v�sեp3?KY��� �37��Qx��A9;�|��ͧ
�R���G�4������%���4���tǜ�p3�&��!��pFX���Q�Lh�D��u8"s:�
����q�rYeR�SJ仫�8��톳B��;ޡ���V'�@i ��w��8�����%�Ϗ��+y�+[�o!�9ȕ@�Ƽ������}7?�����wU8���s3�\.d�������~�ϒk�����{��<����]��~��}.����8��Y�ێs�����t�J����w�_�=�.�3CCA�z��"k�w���{�o�{���i謹������/�{�{�=u��{�]�Πlj���X�?��O�?�M1ܯ�S��wO}ch�{�% �)c�{�=��3�̟yO4þ,��3�=u�5܉\�禎��L��tO��6Q�>�=u��m���+��m�����!�]J���w��w��c5���:���w$#՟yO]ɇ_?�=uȂ��~�{�,�=�=uЦ��ϼ�9����{��侀��ɰk�{�i��`�G3��=u���i�����ٖ��kq���=u��mî݂�Ի>0�{�G>0�{����vO�����S��ql�Է�8�{�v���W���a�q07����WFs�!�n�=���{��ԛ�{㜠��x���v���ٹֶyv���er�=�ݞ�%�K�{�<Z1���O��|O]��{�=;� gd���?�����Y���9��3��y�e��=������%���Qk��7�Ӱ�}����{Ế���^�Oׇ���l������Y������m�������wʿ;��C����~L��=��������>���8�9Î{�g��������Y"xO���{�̐�A���g�/һHo�c����
�w����P�
��w��,l߁½{�_�;Pgw�^�wt�e�x�,噒���3۹>þ#}Y/�Ľ*þ3uG�}g���(�#�~W�}��>��� �`[�}������g�w��$��5������a߱z.þc�J�}���L��ՔL����L����L��Ue�}Ǫ>Ӯ�5�v��g�|�3��W&ϯ{�<��Z��z4Ӿ���@|������L�{�<_���#�Ϡ�M���$���ȴ�l�M�}g������ʴ�l�ϴ�l���w��g��*g�ٚ;ξ��t�o�%����p�Mq�-��Ņ��#*�y�ҞT�m^I	������R~ϟ�ޥ�ѷ$'J�n���v�/e
�Gq���7�7�G�c|.{�<=�Gu)�j�y��?V��c��z��P��?�K��s��睷��V�1@>,�i܌���O�\L�:��8����B�<Kp�@��$� �z��u=7;�����{��01F��e�#�<���xG��U;�n��C��
W$�.���:��H+�kȞ�(�����j=����������ƣ��{��,q�pL�)#{�ؿEO���?�]��_��[c�����Gy���D|�=�\��k��M�՞�/���f#�?�gۣ>��މ��~?���TXy�<���ψ�8��(�E�}�?���G�$�q�~������w�~z�^H��.�Y#�?$��'���Y����(��� <����<�~��8���?�������
���I}�m�wmp�Z�ڛ}z��Ӱ7���;�-�
�ۦ��8�^�lt�Ilk̝��թ4Z�(}>._}w����%{�;)��
�
Q��jO�aU UooPB%���w�w�[���nP����I���+�NN�Z�:��Ok0�7��S<-�`�B��9����\}��e��j���[����UzB��*?��Ki~xt{�g�����k>�$�3>J/޴�o��8)��&Ba�|�K�2��R��g��m�/e�|�K�1��Rv�M�D$�ƛ&�=�?e�|�Oه7]��&���|��yp>��ϸ*��3�ʑ���ro"l��g\���3������ro"���3������ro�؞Ǜ��x1xo"��g��x�P\�8+�x�����V�0�J�DMY��+�xq:o"]��X��7-�yx��7�Q���-��ܾS��ග!��"�O��x"0�1�����a>f���C���a�g���>ü�0o3�[�&��k��s�a^c�W��\i��
z��E�+Mo�>���}�3rv
l�L���S�+�B�p���sIO�-�ޤWE��R:���j�vI/K�[#�����#h�5\�T�k�%L���I;_���p���N􋃼�?h�}䩟�_�S�	�C���m�-��P�=���&i?.i��8m�C����W���&p)Ԝq�.�������� ,�+��0�_���磧���L�7���LzG)�3Q��l�렌e`� _m��R'�K�>	���V���9O`};y��T]��%���x�%�Ͽ��+G�=��������7�iJ��W�>��h���"퓤g���s�����.O'��WԼ�ꂶ;�)���M��"i��c�^p��}�J�K�	�	��2ß#m9qmB۬:Is��U<(���]s2���?���,Ew�<���'o����>Z�o#~�&{��1_OD[�A���Κ]�O56�����Y9�gȾ�5_(��X�门�>8�'������څ�����_\�:*��|/�c$O����p[�}�S;�b�7�G������hܿ,Sc	4�J;i�
�QR���0w
�7��?�)X2׽��t�$_$��A�ʥ|�@�g��Q�)d�2���cb}ux���M��$<��qj�g^�v�
ގ����I��H��~��Ǘd?��8�n��t�)��	Ky�+x��w��A����~"��Q�Y2?c�B��&��!G���%�?�o3$ݿ%3�$x��Ǭ����ܧ���"�{�|���>zc������~W]�����'h�ޗ��A�䇙�D��ɾk�%.S�K�m��K�������ȟ�u�<�p�P�җl:o��5�'�o���z�߷���u��x�7W�[V�j�|�y�|��K�Խr���)�ԗl>�o�d�O�R�3R��o�I�?�3Nс"��M���W`u��&��"��U�2]N�����O �2S[(�̈����à�v;΅�q�s����[�)��"���8�%^Ks��<<H��;X/���}
eL��j��Rc�v�����~�����L�^�8?���G��_�I�>N�9�uZ��k��U����9�'����F}tI�3��U
��������T0!�7 ������d?k�] 5v6�@0R��kf6}P]=��@���:��?�p��U�s*jk�_X��mP`��P�%
�h6�ĒqWk�u���g3�`�Z����)��̴�
aV#M~$�c����%�(�wJy��/K�3Ya�T���Z�.ГEkÔ�s�]RE��;���

�җ�.�0~ ��>���v� �#�P@����X��_ɪZ�����x�W	�*L���#P^.���u6Ż����SLPǌ���%n�o%�ʠ�f�i�P�bֶ݉.� i�gv1�UR����j2�[�Ꮕf�v�/V5��Щ�0���OR6ˋ~�a�[ߗv�_��Z�uU�S��pK��.M��䁚�.������JG̒e��>���a���Jҵ�E�nF1N�3꜑���,)�Z�v;��oP���/���u`ֆ��}��i�#��a��4�%�2�)c/�x���qr �6��Wʑ�c���йj�"	�}"�n��G��g)}֘w�:o1J��#�|@��2*�2.�3� �����S~`�>e����*������n�3�N��kv�6Ո��x �l�������\���O�$��T�;���i1׊y�?�x��S�{\K���m!~C���p���p�w�p���^]�g8�A�g�}ߙ;6����,o<gx��l��z���3��ag��`i]̯�Կ)�z������8�?��y�����ƹ���L����#���ʦU���_�5~[�����5F��q���/_\c�=�C0�8W�3�
�g���t�ƺ�4�qu��Ձ�v�����e\��^|�k���0�q{ ��@�;
wy�ƒ��qt�������_i���I>o�.�m�� �r2�~>���M��e�}_ '9�+�{M y��m��_�ݫ�|;:&d����]�O��6�s�~ưc]{ް�ƀ����HO�~��o/H���o��W}�.O�7m��ݶ��ݶ���������
��|�����~��6��P�����ic��?��X��dY���[&�ڒL^wJ�j2m��g�l]�6ۧ3m�m�,����L^���>��ic��a&��%�gژmOeژm��61�^"{��8���nW��1��5��D{�8��8������P]�[��o��}��G�8�5�����p��p���1�v���~����qL�q|�v�3�n����{����@��z��wz�Se<��8�צ���q<�WK|��a=��3i<�+e�lw�3��.�7��1��gyL���m��[�3��Z���v�W��1�֏�1�>3�Ƭ��x���ۘu����t~�h<��;$���gz���ߎ�1�~1��Ӎ����,K��;;���|�����ʘ`c�M�`c�͞�w	u|��}�a_2��̫�`c歝��^��`c�}n���w��!���`c�}}����GlL��x?�F��o&0�ޮ8�Z~���Yޗ-�e,�9��%��WlJˈk�b~�wQi)���묘:lQ��Η0%%�/O�r�H��b��\~ϙ�(�r�3��@�O�U4��.�^d!l�n���� �����Ɉ��� ɥ�4����D�PKD[��'r�X��.v �0�n�|�"+�����ĥF �\�XKt�;����X�'��G#��H�	²;�+�-�f(_�1 �$m�(" ��%iu��X��r7�L���TH�T�G�U�oZ��6�Xp��QՍL������! d�_%�42�O�
����봐'}� #W���rs��!C�Vϗ55J)cu��Jm�؆��K�*`8S��izB�v���-$eJ@Zx��PXQ�w�5'[͵A�yZp��6%:��I7���U@�����/MUz���Ũ<��U\����?$��M��K�Y�ü��y%)���\���f�����+�k{j�������B���0�#����[H=�(����܏�	�GG�V�XH�V�k�k�f(3dM��@�@y�	N
q�{��g�P��g�;dQ��:NH�H��
�:��b�G�>2øǖ
�9n����zl�i��Q!��f���6m��*'��:��{~���odr!�%��-���I��p�>E$z$W���@_�1��1c�z����a�.	蹸V����g��$��ҧ�˷t���.�p�t�������S}e&��}���z���y͢u6��ٜC��	��n�?��0�c`
��ǖn%���to�p�0o�1,��A��Ü��Zw��*3/&<�32��?&y@�钸����j���L	��\�е0C���Π�:��X��ZZO��]VܫC�����Q��
ŭ�<�c�Ӟ��v�8���I��~����A����eN���$��njẃ���e!�(��Q�}��e��v����m��m�\���J�R���j��)�6�e�^��KL��e��"	�y̕��Ü� |C̛9zm�z=$y9(�ȕ|�sx
c5����yo�|���z�c�9�)������ܗ9+,<	��@�yV��=�N��E��ߧ������S������?������ޛ�i��z��w���f*끹>]
�ܧ/u�*j�)�5o�h�C�����7�������<��:A�2���K/q����'{=�^�1Jq�Q�m�^�����;�����j��s��T��;��_��
��Nl�::6������[�
�ь]��z��zS�O��v����C�%��T_*����)ٕr�4#��=�o���CϽ ���S"a.���;�^�5�A�zM�J&Ο�ަ�G�3��燼~2 �&�[e�w����D���y^���[��K�����s�J���ƙK��/�)e����s�zAQ�E�u��5�]�N�i�N��|� �WJ�J=:g�@��1�����{zB}C;ϐ<�s������y�{gjש�"�Y�}%��/ܤu��=@�}�|D� Ji�����S���<o�x�T�[(ϏS��_�#yF�gh�6�3O��RZ3�|F)�9F>�t�j�!J:n3��u�P��r7���I��"|�<ig�&PV��:�����^z�cϹ����/������OR��F�u��Lմ��������X=���,ќF:�������rد�]H�~~G��ꍴQ�LY��v*9�����qYG��/������!�s=��/?����a}�(a�Ga�s���u��4����XR�@�,Y���Aۏ����Au�%�O��?�÷f���:�%�nz�����8�|�Q{���v,~������Lz��i�g�O�>��t��ҳ��������6Ͱ�h�}D7����oJ��&^�y�r.q�+:p�w=����L�_}_��:yR��?u���$�(T�wK<W.�o;�]���rJw��Q:Hw�����C��~�H�N��$3�c���:^J����N�-�##zO?�e�Q@�7*�}Ϋ�9@��~�U���g�O�O��{)�T*�;�����ϷѼ�w�8�7�W�X��?��{^ O��W��������{����O��$M=�������[�C�������B4@�.��m��������%���Φ�����4�����?��~Ȫ��R߃^�(�Yj�Wm�C����	M_*�-�|Fe_���q}�T�����|���H���t��t�҉�!�rI�,��>;=��|ٗ ݳ�ƙYjZ%���/��ʡq�C�M�x�[�������r���?����k_&�}�\�m���ǠMB2�~��v_C��Y�n�)�(����e���Lk��i�+.�k��3ꕎe�ۘ�1�o�5��W�|�ȸ�<�],i��� |�C���_�s��o.����0w���<1�������9/Y5L���].K�Q�iJ7R��א�2��ׯ~��G����Ά_C�Uߩ�_��w�74�%?�3t3�K?�|�U��үw����k�	����7�ZP)�����8ǥ/-��8�]zZ��K���l��Pz^D�����>V��*bHh(����'f��B~Q��p������w�R�%��X��yH�����>r�W>/+���ש�E��2���j�Is��(���4��#��:�[Nu<U�COx�$Zw��оS��	5��
�Y�����yR�uG`�鳮�ƺ�����M�
}+t���tgh��3���������������)��zȗz�Y�<����T�2�o��=p�Ƣ������u����CC��q�L0�Md�w���=Nou����nǆ����Ǣ�eX
a��V�S���i솪����Z�rJ�aS�Y G,�)28�|4̌�c['�eq���Z�Z��Bu�N�8IFq�n����ےm��uQk��XX�&���\@�W")J�f����;&�3��p�ֱ����z�ƄRlukP?d��$9��H����tl h��e3�P�&��RYDQ�t�$��f��S�gy,y7����q�W��sFh*�&��ʤj�a���F�L�P���Gh6��AW��
-Ku+��g�R��눡J�qt�p�n������Ic&�ӹ�:�zvLxvL&��c3���c�-@L�$��[�f���B�d
���	���r �U��W,��T�Ɖ�
��e������q�����n�������z/������	zf.Ѝ1�^O�?���	����	��S�:�醝T���w2'q9F��	ziƤ��z��ʟ�tW�3�^O���Ơ�S��o[������	���w8΁٩��c��X�~xt������H$՟��Sa�~dt��������z=�tt����s��g�����a�=��z=���0W���^O��n�m���z=�w�Y�}-����X2��_���/���~fص[P���llz={��M��c��y���z���^���Ǧ�3~���z�����5�	�iz~	������ت����b�zn�������-����u�g��{v��q�^�3���`{�v�7T��,���S�0j��9��g�)���z=s=�B�t�zv^Q\��3�[���{�8�Z��*�~y����;��Z/ډ�^ϧ��"�ьztPz�����t}h���^���)�l^���z����O:�����^�Ӂ���1�ZB�'ڏ�Y�����z=s=^���z3u�A=�%�*�x�^�)�g�tz=��Uz7ik�pf2%�����W�h����v|����[���$>��/��r�o�ה_���w���s�o�a�W�{y8��r����_F}�+=��l�����E�a�o���~ ��o�3���]C�M��9���c	\��@}���X@��ݾ}:y�(or����|���o���e�wǷ�������Ћ� P�
��@}��h.�c�w��=���X��1�r���ɗ�ϼ@}�
����8�K��߃R)?����{I��/�ٸ�7��k�^�Sw�5����z&����o�1��PS��m�m=���zZ��z>5�����zd<�'}��_o�9��񶞃?��֫�������������ރW��z�������{'0��E�o&�n�z�H�_��ǵ�kR�7�z�`�Q�PS�º	���'���8�֣��q�Q�ߗ'�zyV��-l�
@:6,��
u�ZU�:֬�u����	�=��%�x����/��(���:��ڎ
�&dK�TnJP	�[�lVJuR���R"�������h�nL6�&T�M1���Y[P2E�֒�u=AYZ(-
L����:�D�����FhmJf`n)�'�c�����lh��ԗ�1E�l���yx�񞤚0FVEk�и���Q�K����_��υ�ג��Ѣ�b��os��}3~���y���|0���=����k����_�_Ǐ��U1ܐzv��������	�GG�V���T���d���ǥ���x>(�y��|�i��͒����	����8rz���zZ�o��eu�ڧģ�P�#���	(3Nٱ��=4�p��p��u��D�uX�*N���`�e7�Ӹ�L�y���'�!��1��=d�2�?7�&�?�'������	ٷH���$�S�=��<W����|�i��<�ΐ��y
�4u���aB/��i>O�d���9�����k$�|r�����4��}����n�C>����i�1��-~�{vL{�y>%���|t�z���}����<��~���%}�=���C{,P������7��,��Y
A�C|��^W�=��ú7_1w�=H2PS�yF8nw�yF!����A<��L��V?~�Q�>��x0=��lV�s|��?iuw�6��M�=o��Nssj��#k�lii�I�b���J9�V�ق
V�T���:��U��)���cӠ�q�vF����\�ز{
V��{�ϋN�3�|��<q{���܏�v�[۴ND�}���3��C�g�}��-F��	��qd�@����h���-�n���Ym��o��E��(Q8�����=���^z�U�����jCP����_�a�k�o��������x����ӳ��$�&O��j;=]�����aN���N�������I����+�h�+��믰n���º���
��2����Ez��~���NP��_%ڜ�jz���B�nz�5U���b_w �C��n��}B�/0�x^ô
���_�q�A� ���`�W�zt���>B�X��&��פIe�4'fʜH{�g��;N?=�_t����Ft^/ŧ���/{e,/��V�����\��B9���s���Y��/�0��(5���Y��>�00���<3�>&������q�c���y�[0v���Z`fB�$��|b�����
�GY9��Nq�y���>��m6h�M�V���m��"��̕�VKZ�~��u��k�U�&�� �S
k��oY�Х�w�f6o��F{�2�#�^�[��|����"	���I���r?�Ӧ0e,;�����1���Ĺ��l�^�8?�\�a��ϲuݮ�߱��]c�U}}
����XX�qm���t�X�M�r����q�r�A|,�$�w����s<kt|,E���������"��W��w��cuS���X���_nF�?K�{^7:>d��]7:>�o����2s&>�ﳆ�����c�\�3*>h��i,�jƇ��ǂ���i������Y�N�������LA|,��mî݂�X��ǆ��c���6�>��c��������|`l�X�`l�X���,����3<>���~ft��x,���y�� �3�s��{��uȳ3>���ŵv޳������X�{v�Ǫ��x�j�T���ͳ�D�e5>�>�.=[�G+ӳ3>V�g�%۳�̗=M�yǷճ3>V�g�<�H�i�&m��B;܏{��H �(=>VM >]k��˧���c�	�g���t�X��4>��@��{ܰ2WL�2>V��ci���:��D ��G|��~��c|,��g� >d��O��o������+|��|��C{�v?f��2�����v�;��7���3�?��������~а��3��v;����{Ηm�5����ğ��J�`�z�����L
���=!~ �ͬ��_�[`4췇��E���|Ʒ�`���o�͐?ހo����j+��.�gB\^�/��?��|�+|Y�����Yv=�aG8�.�ύLYpN�gC�]ȼ�w��w���"��w�}��ߛ�������k|�;������}wx?�v�x,��]�Ęw>�e�w���������΀y��ga�n�ߒ�e����}��YzW/��L~	|����~	����8����N�8|9����b�p�1��c�M�%БT� �l�-��D8+8E`�O@ԗ��8�S�NB58���T�n�IH9�rs�0S� ����~�o��;�)�d�v&���߾�}�v���w�;��L���g#��g.���Z<����k�޳��{�J���g%6��g%��������g'���g'���{k+/����vA���7�Q_����=[1�7����:�O��g/��{�^L��g/���޳�D�3ޥ�W8g'�����g3V�g3���uP���������D�o
X�.�
��9���_�|���E�w�\>��E�,����-�/�����O*ʩL�Z�Ь��I<��l�$�N��rb��2�w��-��ɯ�k�	��\j�����.��uP-���|������rwO#B�w-4������ѿ���nP�~����#יk�A[��?�_?(�[�)yya�����q�o�7���/2ߎa��W_g�խ/?�o�S�_/P]>�n����Η�x���,6�����?Լ�e��(?x������Q�����$b�1^����-���☍-Pݸ�R��������H�>�����A���-�oPC���=!�'�)eU�5�~M���-s��6ք��!�u\�俇zuP�.�������㠵K��h��d�A��o���������c�����G��w�;q��~L�'^��13_�_�m���G�:��O�;�j�_��]@~K�������|��	x���u�Z��^��\/�[���2~��{%�S��#���^ye�gNA�O�R?*y>��:��R�;������/����Uh��f|��Q�����'o�|'Yq���X��}�+��������хv�����|���{����v�
�gI�S���{��_�@^�g���j�)'�x����H�,^.��oT���[�y����?������w1ʓ�m�,�{XW�x~m����-��D���1mhÄD_l��zf�W�aV�/��f�\L�@�Q���4��l�q�
-�_�q��s톖
m�w5j���CΥc�p����un�C��P3m��@���N�@)�7��
��G�5oi�|&߬�����b0�����t���א��BK����	-Z!4,t��J�˄F�V��lh���B=(t@�!���� tP��G��$tH�q�'��"4%�WBG��!��з��:)Ty	-Z*4$�Lh��
�a�K�V
]&4"������>)��R8�+HaGIak�$�O���O`�¦�%���$�>���w��Q�*B
=�&��XC
G|)L�()����h���ZR(W���%�mRG��AZ��Ha�5��wk!���F
[;N
����"� l"R��ݤ0���ն��&�A
è�>S)ý��)�Ia�%I�����78@
� )|�R؈�H��ޑ~zG
[v���R��GI�@�D�
zG�q�)��7B�Ho�ޑ��ޑ��#�zG�zG�)��m�;�OC�H� b��;��a	i=�zG��#��QN
ÿ��f��zG�y�$��O�� /��a����c�y� �0�WL�:锓>ᤇ��Q'=�;�'}�I'��^'�뤷;�n'���N��I78�:'sҫ�t�I�8鈓�t�a']�CN��I+'}z<�>�G�t�I�p�CN���t҇��>ओNz���u�۝t���r�q'���t���9��N:�k�t�IW:鰓.w�!']⤕�>=�����۶Npێ�y-�uA��}�DKU��e�"�u�GT�W��[���`^�e6m0�"G��K6>y|W�S2�o�Ć�~�B��樇Rs"�k���ľ>�-Ā���w��O���s<���ܸ���{<K���k|S�-���4��I���Q;3�l���~իq�|��'����_��������2��G^!�
=��Ad�%��z�"�iby��j�/��5M�b���W/��H�ft����/FÑ�L8�-���Q��3�o�к�+���c)Oo!O�R
2�5��v���pشUD̑К���9�G�+Eo��Z?�����0x�?�̫D��
t?����L]Z<e����kԟ��A��.��:Y�:Ū��%/)Fz;�-�G�կj�F��}��4�ʧ�s��"�5ib��X/�'���9���1Ҍm��a[����ޖ�\�%�G��p��AU"6Xr��FW�]y�S�+!��GE�vL�;���r|p�O��~U*�=���=|�ߟ"�W��!���&��חym��cBcn����%�Z��Y���92)�A�u���v���a������F�����ܕ��?��hX�:���ӹٻ��@/h����}A?>9�><%}��~r����Y�:�=�����
���1�����z��U*�B�)���ֱ��gL��WByX��rW:N�Լ����>���^�5��5:�����{Ƨ_��0��N�@97��k��O�k�8�?��'?��<'����Q��v�G�/þF�����~�W���5[���zu]z��;Q��q���ˬ��z���]�ЛiR��~�ܰ*�M��9��hg�81_weJi�����Pb<�0˾�I�ܓ
�Լȱ̇�g\l^Cw�X|���0���|/�?P+�WH�|��̍�5Fy�8f�k��s��wr��1��_4�42��k��Z�y�Kl�W����e��5�� dѠ��_Ҳ�Yh_(���,������
mg|A�b�����~��c&>BY\U ��E�[��6���i#ؿ������VUwz.�?f]�m��EŻul�{�ec�F`L��Z��ܥc�x�/,�r�b?��v�kWȌ���s�ȳF���zD�����ent̥`nN���MB�fo�3�q���2��|��F����� WU������P|@�A/5���$/5,�%�>5v�5���h��� (�(����<�,���2-��u;��S:���:��.3K-����;�BbM����{��n@׵Cgx��{���������=��w�^�>)��O��X�g2�0�.t�M
s+�����x�S�,�|oz�;�=fT�=eg;��L[��׀�쇴�����Ӛ$��_&�{�8��J��W��k=�)F�Z(L�G��&��'^���>��YM|/`z��ǿ
���V��Z��F��/l�a��GrN�ʹw٨\����S)���@ˁ�p�&���4d�5��$�]�=�d���^M�$� e��	���F�5J��O��l��A�${Ɏ�l���Q��Q�k��.\�o�� \ς+�,�\��i�w��s�8SK?�A������3���#r��G:�H��Qw����ܗ�O��u$?��w��"��$?F�#�|w=��O��7>����^�A���ui_Oi�������Rk�����&�v�~6�WD���m����z�6�yxQ��^�}��F(o��Fq�n-�gv�`�c%��h�96B�8��1hlT��Gh.\� ���Tx�����>ZO�Kc�7G��?�ٶ)ɏj�H~����5$�_A��5��4�/�y��K���=��Ws'_oYc7/�B>w�(ӭ���Ɗ�8Z5�He���哮Sĥq?��-"�Yć��3\=��}��j�jn��Oꩯ{���:�I�:w�3�k����������l�zg�e��~w�����@�1-��R\�|Eu~f������l�������F�(���51�sD✨8��8k�8��Yt|��>�C����w��r��1]����Ƿ o���hi�wũ27�Ĉ��N����/-���~ ���g�B�=���t����=�[fIb��\��3.?�\���4Ĕ��t��P��Z�L��AVо�dJ[����Y�_8'�l����d�݌�KZy,�v��r��� ��/ }���q̤�9��`y"���g���c��}��4E�K�9������|Z���x�_��$�7c��߹�d1�[&��#x�C߃~\XJ2g(�)ү�t��ǽ�q9Vk�h�&���?�uţ���^p���:��Gy����l�z	�Ɂ�C4���\k����u�w���z���i���4�vR2�ύ��7��5O?vd�I�[>�/�U1�}��O�>d#�W��oW��^��
��'�Y�
��!�8�h>���z�v��|s#h��tua�%��흐��P�B��N^)F�{����
x���� 
ᕖU�\\�jp+���XV���i
�\�>p����Wn�>p����g/�`����
�P域l�V;��zӢ���vX�U~�͔��"�P���G��*�3�w��}��o����G{���r�7M�����+$F�3߿B� 4��#W�����ț$��;�&Y?��-<�Wk~�����ɠ�}�N/���{
#�}#1Dt���q���(���5�F���W!�4�U!�i�c����!�_a��20Bj��0BZ��4�x��1B�̠���!�]a����1B�V
#� ��]aD�'�'�p���0BJr8FH,�c�ܑ�1B���!�$Oa���9#���������V����s��
#d��
#$7�1B��x~���)
�r����0��
�jp^�K��;��)n3h[�����L퍪-Q�����N�?ꇻ����s�+:�T�m�>������oQH���G��z�^�eeaԾM�ď��mI����q�k �h>�Z����2��w&��S�DS�+��>��?�'z�
���6�Č0�gz�@��
ȷ��:�H��9S���D%ϛ�~*m��U�ӷ�2;}�ޫ�y}Z8�w=�ݝ �Ei���NSu%O�f-M�A��L'Ё�$�N���*�G��Oݾ���4@�WŸ�/�(����2�e�5��_��?ɇvfd���
�W���uT�93!=�/1�c{��2���'c�����Gʹ�����c0�z�@9ɴ�{ �ѽ��w�/{WVU��Ͻ �^D�&� �" !�(���)�j"&(
��Z������˵UӔ�n���-�Zj���˦��Lԥ$����?3sΜsϽ`����}��3sf���?��7$M���/�Q�9�w��,��� �����d���H��o��6�������Yo�NQ����32����L���t��;�61�����&6�f���
��O�K�$Io�'�zi�,ic�?�G�48IZI��+��W���D���ǆG뉤��1\>���1<�����Ų�蘮�����m���}i<�8�A�Ǡ�7F6������όK� x���9���zR�#;��� }5z~��h刔��#u �ϑj~Yz6��; �q�L��r��O�K?�=�b� ���9[!�f��M^d~�^�_#Sf.�����EH=��O�?�kWz6B�L��	��2  lp�%@4X�9	��(�S�����E�p�Yv�� 1cF�3�c��_<�FˊɅS�ٙ��"�Y���j�t����,��z2��-��L��4'P8�)������.�l6��֔������ �g�=��d�ְ�T�[W��}�|����6�u0��o]�	��:���)�|뉝�|k�N�o�rT���~ ��;ܛR���UH�H t���t?�LC��?7��|z>��>��>�\���\��R~.��_/?��υ&h���!}3�
J�����8*F�9'�mP9�mN.�eP�qr��*�v�9��F@5;[��rr�퀲���}I�PY�c9���T{�\���,'�Q+�XN�.�o�N����={)sm�1��<������z��s�&W�|��[Ɖ\[�VՊ�����w��~O�;u�X�/�M�k��̟�M�k{Q�oke�m��_Ee��m�?��2׶�JʵG����?7�xi���x���)�:�6u����o��Oε�WQ;��B��b�K'jǥ<Q�cC�`Ǔ�
���g��v̵��L����o˔k�+�qͤ�>)�v{!�c��A��/�;��
v̵-�D�8�&��#j�l�v��l9Rn-�/�%�v�����=BX�`���0P������0����4)�����`��(�7Q&�.�ߒ ��͕WB��[k�v�[[&�L~3cn�v!<̭�.��̭;
S���/;�U��*)�d'q�ؓ�TR�ɇLxPF'd�/UR��7ĝbOnɰ ��sN"��ݜ�b�'�{��b?"d��@:{���ƗL£؍lb�ؓWe�mdH���v�N�'FY|w�=9��bO����[Y|�Sy	���N*?�$ؓ�;�l8f�gf�g6���o��{0��y��xs7k�3�������uw͍P&E(2���B%*�|�%�UPP��C�<h
Bb�<�,S��D� ŐD��B�W	X���X^���Dl�/��>H?k���ٙ3�[ �v�C�����PN��#�!��>����d�:G�>�7�+��?ۆ�������mX�-��܀��;Й:���i�!aVޕ���x^81ӣC K{�0��=7L��� 0����#=`��]oüc��М%�����!�ST�o&0�)"�J�7`�VRtu��"�����C�Q^.�����ugn��.��amB�a"s��pɰћڝ�V���H��!��!�6�p�a�&�"v�s��b5=���|�T�Fb�D���b�O���*��`.�"�+�Q޹3n�^����~y��$y���!�_O�cv沑�ˤ7�w�	o���,F��?^&��L�sHO�1��?P���=D^0��Q#i%���I�O��E?��l���\�^��d�/A�N#�W�k�6v��K��yƜ��t���S�0닛�5/(�"���egd�\�e�[���S*��5/s�S���?�-���[4
i^2�Z0��\0G;=�݂��E�gT3�-`���+��`V1�f�li�|~���7O$
�c���R��.�1K�����a�sv��^Adv�Eչ"�a��7��ҫ<���������Xi;]�YkW��V;#9
i�Ѝ�}������(>�.�ެ��ܵp��(�w��^0����rH.��V����4�%n�S������ �n������]�������q4�8��4�ZH�?�z�_���������*X�K���}Q������Q̱?.��0$ I`�t$�WP�Eh=	�j%���׮��v�a$�a����ݙ:�\�x<�;)#������o ��ن_Z��?2C�>H����<�}uG�OG�x��Dj��sw�9ʷZ�9�&�������F�����ĸQ��Au��7g	qn��3�iW��w����NF>�"W��:��/
��k�0�@���ƳS>޼%!{]�B=^|ůf�3zh&����S/,iiIFլiY���[��n���;�x� �͈�A��]lx}B���
-䑈�y|"� bd$�4�sg#b�#*�/9� 1F�n�
�a����x78+2��W-��8�*xV0���Q�,����j�V,�?S�*=�)嗬v����v��#��<pRV`�尢n��O0Q*oS�z��>��>3��%~���⡫W��+���S�>��^v!y�KW=����^'���w:��Sd��9�F�Ht�Ww�Z�K�i�{#k�=�pg�՗���b�kC.�'
�@eL�6��9ۜ1s��N3s�9c�M���1W3�ϐ٧���3.�kv\�
g�j�l\@��+���J��+�/�͍�JCm� Z�g������+�7�������;(����l��k�]�r%�+�Y��'\x6���g=�
X\��q=>5X��S��ŗO�����q_"���%y���
���Y�/I��}!J��O{�#�u�bX��P��q�8�u����p���r�������ݮYv7�{�i�-����icZ[�R���֑Pu��{UqBڠ���Z�izg�9��#����}�{o����;��<�|;oޛy�}������Y�	9�L�A�6�������ψ�1���e�a
���Q�|��4�O�6xt>�$2^9z��^$��m����j��z5�;����|knG~���ņ>�|�}�ߠf�E��lY�Χ���_@�ʫ���-��Q]7|��{N�:�НO9�Y� ���r��e��J��{-��8�}U	�(J�ܹ�3�ű�<��?�I��zCe��kO�㥣e���Y͏����~�?)�am�k���]��ٌ����_5�c�1��7��O��w�k��մ�Ѧ�{��o�bw��G���9����9��n��F�;ǲ��5�s,��v�m��.�:9�W�_�%^Y��x";�
��O7��x�5r,X_j�űl1e
 e��s$Si���d*ur� 9�˦L�k�L�vÔiFSΝI��S&��)��ʹFɱ\3e2�˹:ɱ�L�J�a1n�ː)��QS�eؔ���K�Fbc�L�S�u��./wȏ8�s�^���w!eMr�̹s�&8������!���/Z��}�8;�r�����떚�7�r5{���>����׼���vnԬq���ݎ��+�4�?��~R�׬�C��yEƑ�I����K���(2�]6�[��^d����M8����m��s\I_��
��2r.���u���:�ƿ����ݖ�\��&~��m) �s���C�Z�
r,��c�����{�9��:����W}�������C���|v���>���+��_u���>��YM���W �\���7}b�[|�������z�L�]���9Ox\�4
����u:�8���q�zٷi�G۶[ϯp��s#V_�>.�з���p\!�����/
�"%ɯ��M�V��2�:Σ�mY�l;�+�_��H��%<��_�3To�*�o$��{x��'�����x���ĳ|�g���5�r�P���r;�����#�=�{��P�(�;��-���z�rm(׏)�L�^�\7+��kM�����|T#����~�-PO]]�9Q#s^02{�Q�Q��ii�9#s��
�-pEe�v���u����+�?�������q�%\K�=������oNlzht�O�N�ͽ�V��
G�*8�#��7~��/���.��QG�K�}�#��8��}7��j��M�92l��Mw��ʑa���S�u�Ȱ-?��:G�}����T�Ȱ�pn�)*qd�;F�u�T����pq���ɑ�\w �:Z0=�������� �/���rd|���:G�s��U��h>�:G�}��2�T��Ε���fqd4�^�#�>�X��zH*G��t��sd8Vn-��srd�����j�Ȯ6�Ƒ]^RGv}ImYjim�٥�qd���6�,���#����qd��jڦ���)G����L�J�KH��)�E�uS�T;g�d�s�#�6e��ǤL�*m�#�d�đɹwɑ�a�T�ϊq����L��1�L�Z�qS����d12k�2qdͦ|wpd�"�$�������
�Y�J%�_�J�R,�K�?��%ϫ���z�����S;!���Yơ�n��R��p��ǂQO���V����D1�_�_I�+����ʊ���T�]Y^s!tP��������x�Խyצ���*�*�޺s}�ڲ}�f[9m!��~����l����B�8���:�=�����k�%qa�y�Gd�l~H�6�o3�R�nOX>�	���������؁�VJ�O�;�Je ;Ĭ����U��d��R�����{�XOLJ1;���H`qӟ7o�gٓ۟������?��A�b�z��$�`�^��P��m��d -��>�/�I-��}�Hn��&�X.Y>W,�r���
��ի�g�j�����`�z`e\��߈Y�?Y���^�_�Z��쾧j�7*���A��V�����]�d`�3�����<R26�KY*YHbJ)��Y��\1+�9��j���|2�t�˘ʮZ�/��?dD�!O���\�_��P70�_J������D5^x�=	���r��jzN�ww���}d�?KӨ�WPA�K����i�aG�P"[�� |Ov��bz �(
�l.����f���`��d�?���\v�#]p�ƙMb��L�����$�Y;���:I�V��Z�3YΕ�2����R�7��	I�,�G�f벻7�m�w��3�w�/�U��sem�T2�RB��%hg����#����qwG��h���Og2�L��Ih�hOh�{�����9���o��8��e�?
���k���fo��[T�<SW��ρ����C!î�h���ߺ�[��μ��]k�왁=g���}���`0��?C;��uq�S�d���P�������b����7n�#�P��bqO���<�������>���� ����� �����q���7bAo��z�Y��pt1\co�@�e��C9��J;��`�їt�����I���`�\6s�ël��sb ��?e�1��p��4��������>�e��M���r�N�H��Z���3y����ߛ�aw��=۟zj�N�)�i�g��٣��/f��<��+1�����D�0yb�̫��/jނ87m��� X{����r�S;Y{F��iu��,n���"o�����%`��߈F¢��� ��p����W�ף��tw��Q�o� X��g�o��GBh��ż�_]�]����r�]�suwU�Y�n)�j�?�����b�`Dc�9�Ɗ�>�������V�Y�����������<�9�y�s���<�9�y�s���<�9����?/#r�                                                                                                                                                                                                                              simpltest.tar.gz                                                                                    0000666 0000000 0000000 00000011557 11162434065 012746  0                                                                                                    ustar   root                            root                                                                                                                                                                                                                   � 58�I �]ys�F���ħ�%��S$r�[�X~q���%���n����5	pP������  Eˎ���"�>z��=3���zً�߄��K?N��@�����폝�۶��p0��}{0<= ����@�8q#BDaX����(����x���^D]oE���"&�E�:�{��#r��p�5{n⚂CC��>��a���#j��)�ʧ�Z����oؼ�G��{��4U�	��4٬�]/�$M�y��0���z��g���`l��N �8
�~��P�|�&�1d%��K"Jq���@A0�1��q(�#w���%�8�^���].�kV�-\����W�ϕ��
�����l�Π=l�[g��A��o.�&�s�<]�B��b
�P��k)hF���)�\�{
�+���,6��f�X�4+S�0de�,��7K6�S�8`��`v��{�	��h�Y�Lj�	� �2��A���G���g}
,6�n<�)Nk��:&N�M��2��J�c��0��#��嬤�rPCl9�����X��&�1�e��_����|�	��n(h6Ք��1HLo�P�b��b�Ɇ��7�Xd�OA� �w�����~��$�"�|6��~"���f�6Sʑ�k5�{4����&��MC�^`]�wU!��h���m��P��[*��Io�F�
0&s�GO[:ӫ쏍<���S3�
��[O����:�r	�bB[� Q���(�Z���*[�$��)n'�$m�^��!�'@쩡�̆��#ӓ�@���VRV��˩�A�LXլ���b��S�A"�Z=p����L_,�bW,�.������C���r���/�xD%,v����bʧ
�z����!q��f�4�n"�W)��OW N��@S�bz�
!����7��?}�?�G����g�_?}uvz��v��oN�l����]����#Ǻ����g���6t�I[%������Ӓm�Lj�lP�Z�*Ŀ~de+j(�'5:E�Ֆ�yʌq��/�l�>l�p�#*Gk��m��(�c��"2-4��<ѪI�}��'����pSe��"���M�9�挜�>�	�@`����eL�	m�P�
�٘ۑ�e�O�r$��H�gS_���Z��կ��fЫM��}��b�z���T�E2= �I����7��8�������A��4�����O�����.�%�:w�?��N�>!�x�����P��Ǆۉ��������
m��6�M���(ۆ���+��P�&�a��R�#Ɩ@y�^Hl{2M�������$q�!�S�*�71�������/��ѷ�>D�+d�<���
���&J�h���֎��1&[^'5�e��Q��� ��]b���w�M{o]�-*���߳����6�l�G����3lw��-/�ZL���{�;b)~b���s�N�����Z���픅��Hilq�A;�z��k�B4o�R�(�ȫ/�z!E�BB�4�����)�f�笺
,����V��tM�j�H���F�b^@�m��'���s�-��]���dx��Y.��w���B�l.�R65�2�tIV>�Om�Ŵ�Hez{����?�ޢ �?Q��X�f#��0��-��R3��ՔF�+����g��vʓ���a�� �p�r�8'�!��7l���d��	����q�I42�k������@kX�lO���g4p#?��U~䷀�t���ʡ�sR��}dgj�j�_3�9�9�8|aj�;���-�eͼ�.�b��4<���2���1��`��0�rJ��4뽱Ed���v�N�L-Cy���85�+f���T�:�����abq�^h���)[d�*Y@���5n�Y����f�'����C+x�,<��2��V�ư��bq�,=pny.�m���l����6Ρ����=�����I�����u$g���РBx������1q�*��8 �cA�����u?ȳ���~����~���Ӻ�����g&�����Q����(�������^ȸ��l�u��O�eQ�8�w��� -nk��H�,���j�J�h�=+u��V�����t&O�m�TT�*�n�4"uV�%����X�����f� �>	�D��-�Y쎕)V��&6MKrgg@���d~a�uԝ��0A���_��W�����(h5��A��KzZ��;{C���-���z����\���4٠u��q���ʡF]ź��U��#�w��5>�t�:����O���/{<�翝F����?g��H��~�\�z[�|������
rk�k�E�!�Ӕ��T��������\S�=���Њkk���^_�g��56��ը���r�W���р|�a��)�l\��〴���q�k7`Öns�����_�^���	��ؑ7��ބ��!�޶�;��r�q%�ŭr6:�Q�Ʃmr�T���B��C e%d�I)i�|�����*eed�GYQ�/e%�gJ��m�O�|�A�K#��<M6��x�P��+I�Ovx��l�]�Q�^�
��@�L!���8d9�]�ͼ{�����
��0��Ǌk�Ȓ>�B����,+� 0R
�1j ��	R�f i��G�4�ő�o��"����>��V�E�p�dyuJͰX��2,��G?lu�o0������BF��d���_<}����ʕ�>�>\=�~�����w�̡^��,�F���;���o����
92e�G���C��3�̮�t�$t�آTq�_������Ɠ4%;�¦c���	�ˢ���:��tt7�$��&�/�|1�D~�U�hk�G~͕�p@
	9������'��v�%�7dzˆ�"�Z�S�5V|M�FƐ�V/����G�J,b���/ q}Y����ܱyU��4p���`lOF�	��Ol���s/�Ëʙו/P����f�~��]���+�h�oB�B:'�����1�����h2L���|���<˲GX��@�}Ҭ���.�pu�:j���x�_�}{ܬ�� ��O���=`Ւ��kV;�����t��w��e
���n��m&���
�t���[�R��!� ?����?�r<'cO�~�7lK�;�>�x�����VG�����`���㽐q�g'�� Ϟ^<���p|��!w�I�᠖?? e�!E�N�Jy�:����'E�?j���B�����C,��R��\Zk7J�L�M8��I��%k��������(Yߕ��v�U��{���?��ǜ�I��ܭ2�]B��/�0÷��&J%�-�fnB��&1gJ�����@���j���j���j���j���j���j���j���j���j�wF�}4e� �                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   