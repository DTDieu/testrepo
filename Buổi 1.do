/*Thực hành: Đánh giá tác động
HISP Case Study
Giảng viên: TS. Đỗ Ngọc Kiên*/

clear
clear matrix
set more off

* I. Thao tác với Stata và thiết lập Directory
*Bước 1: Tải file evaluation.dta về máy tính; Tạo folder mới và đặt tên 'Thực hành ĐGTĐ' và chuyển file evaluation.dta vào folder
*Bước 2: Mở Stata và mở Do-file; Copy path (đường link) dẫn đến folder bạn vừa tạo và paste vào bên dưới
cd "C:\Users\Phong Vu\Dropbox\PC\Downloads\Thực hành ĐGTĐ" //Thay đường link của bạn vào đây nhé!

* II. Mở dữ liệu và thao tác với dữ liệu
*Bước 1: Mở dữ liệu
use evaluation.dta, clear

*Bước 2: Đặt tên chung cho các biến kiểm soát
global controls age_hh age_sp educ_hh educ_sp female_hh indigenous hhsize dirtfloor bathroom land hospital_distance

*Bước 3: Mô tả biến
describe //Mô tả ký hiệu, nhãn, loại dữ liệu v.v...
sum //Mô tả thống kê
corr //Mô tả tương quan

* III. Thực hành Đánh giá tác động
*Phương pháp 1: So sánh trước và sau khi can thiệp của nhóm can thiệp
keep if treatment_locality==1 //chỉ giữ lại làng được can thiệp
keep if enrolled ==1 //chỉ giữ lại nhóm can thiệp

ttest health_expenditures, by(round) //so sánh sự khác nhau về chi tiêu cho chăm sóc sức khỏe của nhóm được can thiệp trước và sau khi được can thiệp (sử dụng Balance test)

reg health_expenditures round //so sánh tương tự nhưng sử dụng hồi quy

reg health_expenditures round, cl(locality_identifier) //so sánh tương tự nhưng sử dụng hồi quy kèm phân cụm (có nghĩa là so sánh rằng có sự khác biệt theo làng hay không)

reg health_expenditures round $controls //so sánh tương tự nhưng sử dụng hồi quy và các biến kiểm soát

reg health_expenditures round $controls, cl(locality_identifier) //so sánh tương tự nhưng sử dụng hồi quy và các biến kiểm soát kèm phân cụm

*Phương pháp 2: So sánh nhóm can thiệp và nhóm đối chứng
use "evaluation.dta", clear //phải sử dụng lại dữ liệu sau mỗi phương pháp
keep if treatment_locality==1 //chỉ giữ lại làng được can thiệp
keep if round==1 //chỉ giữ lại kết quả sau khi chương trình xảy ra của cả hai nhóm can thiệp và đối chứng

ttest health_expenditures, by(enrolled) //so sánh sự khác nhau về chi tiêu cho chăm sóc sức khỏe của nhóm can thiệp và nhóm đối chứng (sử dụng Balance test)

reg health_expenditures enrolled, cl(locality_identifier) //so sánh tương tự sử dụng hồi quy

reg health_expenditures enrolled $controls, cl( locality_identifier) //so sánh tương tự sử dụng hồi quy và các biến kiểm soát

*Phương pháp 3: Thử nghiệm ngẫu nhiên có kiểm soát
use "evaluation.dta", clear
keep if eligible==1 //chỉ giữ lại những hộ gia đình đủ điều kiện tham gia chương trình (ngưỡng nghèo (poverty_index) bé hơn 58)

foreach x of global controls {
	describe `x'
	ttest `x' if round ==0, by(treatment_locality)
	} //so sánh cho tất cả biến kiểm soát 

ttest health_expenditures if round ==0, by(treatment_locality) //so sánh sự khác nhau về chi tiêu cho chăm sóc sức khỏe của làng can thiệp và làng đối chứng trước khi chương trình được thực hiện

ttest health_expenditures if round ==1, by(treatment_locality) //so sánh sự khác nhau về chi tiêu cho chăm sóc sức khỏe của làng can thiệp và làng đối chứng sau khi chương trình được thực hiện

reg health_expenditures treatment_locality if round ==1 //hồi quy cho phương pháp RCT: Tác động của chương trình HISP đến chi tiêu tiền túi cho sức khỏe của hộ gia đình sau khi chương trình được thực hiện

reg health_expenditures treatment_locality $controls if round ==1 //hồi quy cho phương pháp RCT và biến kiểm soát

reg health_expenditures treatment_locality $controls if round ==1, cl(locality_identifier) //hồi quy cho phương pháp RCT với biến kiểm soát và phân cụm