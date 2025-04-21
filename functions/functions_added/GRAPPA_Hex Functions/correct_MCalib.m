function MCalib = correct_MCalib(MCalib)
pat = abs(MCalib)>0; pat = sum(pat,4); pat = abs(pat)>0;
pat = sum(pat,3); pat = abs(pat)>0; pat = sum(pat,1); 
pat = abs(pat)>0;

index = find(~pat);
MCalib(:,index,:,:) = [];
end