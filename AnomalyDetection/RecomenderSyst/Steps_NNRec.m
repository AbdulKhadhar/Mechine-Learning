clearvars -except R ratingsTbl ratingsDS tbl globalMean
[userId,movieId,rating] = gather(ratingsTbl.userId,ratingsTbl.movieId,ratingsTbl.rating);

R = sparse(userId,movieId,rating);

%Access a zero and nonzero element of a sparse array and view the results
R(1,1)
  
R(2,1)

  
%Access a subset of a sparse array

R(:,1)

%Use the find function to obtain the row and column indices of nonzero elements in the last column of a sparse array

[r,c] = find(R(:,1))

%Use the nonzeros function to obtain the values non-zero elements in the first column of a sparse array

nonzeros(R(:,1))

%Use the full function to convert the first column of a sparse array into a full (double) array

full(R(:,1))

%Use the size function to obtain the number of users and movies (rows and columns) in R

[nu,nm] = size(R)
  
  
% Add your ratings to R
movieid = 7541; % Add the index from the search results
rating = 1.5; % Select your rating
R(nu+1,movieid) = rating;
% Your ratings:
table(tbl.title(R(end,:)>0),nonzeros(R(end,:)),'VariableNames',{'Movie','Rating'})
  
minInCommon = 3;
maxDist = 0.75;
minRtgs = 3;
nbrlist = rangesearch(R,R,maxDist,'Distance',@(x,Y)nndistfun(x,Y,minInCommon));
disp('Your neighbor id''s: ')

nbrlist{end}'
  
[pred,nnOrMean] = nnpredictfun([userId,movieId],nbrlist,R,tbl,minRtgs);
fprintf('The mean absolute error for the nearest neighbor method is: %g', mean(abs(pred-gather(ratingsTbl.rating))));

fprintf('Neighbor ratings were used to make %g percent of predictions.',100*mean(nnOrMean))

myNNrating = nnpredictfun([ones(nm,1)*(nu+1),(1:nm)'],nbrlist,R,tbl,minRtgs);
tbl = addvars(tbl,myNNrating,'After','meanRating')
